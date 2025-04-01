<script lang="ts">
  import { debounce, uniq, values, without } from 'underscore'
  import app from '#app/app'
  import { isNonEmptyArray } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import { getAllQuerystringParameters } from '#app/lib/querystring_helpers'
  import { onChange } from '#app/lib/svelte/svelte'
  import FullScreenLoader from '#components/full_screen_loader.svelte'
  import PartSuggestion from '#entities/components/cleanup/part_suggestion.svelte'
  import { addClaim, getEntitiesBasicInfoByUris, type SerializedEntitiesByUris, type SerializedEntity } from '#entities/lib/entities'
  import { getSerieOrWorkExtendedAuthorsUris, getSerieParts } from '#entities/lib/types/serie_alt'
  import type { EntityValue } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'
  import { addPlaceholdersForMissingParts, getSeriePlaceholderTitle, type SeriePartPlaceholder } from './lib/add_placeholders_for_missing_parts'
  import { getPartsSuggestions } from './lib/get_parts_suggestions'
  import { getIsolatedEditions, getAvailableOrdinals, sortByLabel, workIsPlaceholder, type WorkWithEditions } from './lib/serie_cleanup_helpers'
  import { spreadParts } from './lib/spread_part'
  import SerieCleanupControls from './serie_cleanup_controls.svelte'
  import SerieCleanupEdition from './serie_cleanup_edition.svelte'
  import SerieCleanupWork from './serie_cleanup_work.svelte'
  import type { WorkSuggestion } from './lib/add_relevance_score'

  export let serie: SerializedEntity

  let worksWithOrdinal: (WorkWithEditions | SeriePartPlaceholder)[] = []
  let worksWithoutOrdinal: WorkWithEditions[] = []
  let worksInConflicts: WorkWithEditions[] = []
  let allSerieParts: WorkWithEditions[] = []
  let partsSuggestions: WorkSuggestion[] = []
  let maxOrdinal = 0
  let placeholderCounter = 0
  let partsNumber = 0
  const titleKey = `{${i18n('title')}}`
  const numberKey = `{${i18n('number')}}`
  let titlePattern = `${titleKey} - ${I18n('volume')} ${numberKey}`
  let selectedLang = app.user.lang

  const states = getAllQuerystringParameters()
  let showAuthors = states.authors === 'true'
  let showEditions = states.editions === 'true'
  let showDescriptions = states.descriptions === 'true'
  let largeMode = states.large === 'true'

  const serieAuthorsUris = getSerieOrWorkExtendedAuthorsUris(serie)
  let allSerieAuthors: SerializedEntity[]
  let allSerieAuthorsByUris: SerializedEntitiesByUris

  let flash
  const waitForParts = getSerieParts(serie, { refresh: true })
    .then(async parts => {
      allSerieParts = parts
      const allWorkAuthorsUris = parts.map(work => getSerieOrWorkExtendedAuthorsUris(work)).flat()
      const allSerieAuthorsUris = uniq(serieAuthorsUris.concat(allWorkAuthorsUris))
      allSerieAuthorsByUris = await getEntitiesBasicInfoByUris(allSerieAuthorsUris)
      allSerieAuthors = values(allSerieAuthorsByUris)
    })
    .catch(err => flash = err)

  let isolatedEditions: SerializedEntity[]
  getIsolatedEditions(serie.uri)
    .then(editions => isolatedEditions = editions)
    .catch(err => flash = err)

  waitForParts.then(async () => {
    partsSuggestions = await getPartsSuggestions(serie, allSerieParts, serieAuthorsUris)
  })

  let availableOrdinals: number[] = []

  function updatePartsPartitions () {
    ;({ worksWithOrdinal, worksWithoutOrdinal, worksInConflicts, maxOrdinal } = spreadParts(allSerieParts))
    partsNumber = Math.max(maxOrdinal, partsNumber)
    worksWithOrdinal = addPlaceholdersForMissingParts(worksWithOrdinal, serie.uri, serie.label, titlePattern, titleKey, numberKey, partsNumber)
    availableOrdinals = getAvailableOrdinals(worksWithOrdinal)
    placeholderCounter = worksWithOrdinal.filter(workIsPlaceholder).length
  }

  const lazyUpdatePartsPartitions = debounce(updatePartsPartitions, 100)

  function setQueryParameter (name: string, bool: boolean) {
    if (bool) app.request('querystring:set', name, bool)
    else app.request('querystring:remove', name)
  }

  function onWorkMerged (e) {
    const { from } = e.detail
    allSerieParts = without(allSerieParts, from)
  }

  let creatingAllPlaceholder = false

  // It would be easier to directly call child components createPlaceholder in a queue
  // but I couldn't make it work, so we use `nextPlaceholderOrdinalToCreate` for queue messaging instead
  let nextPlaceholderOrdinalToCreate = 0
  async function createPlaceholders () {
    creatingAllPlaceholder = true
    createNextPlaceholder()
  }

  function createNextPlaceholder () {
    const nextPlaceholder = worksWithOrdinal.find(work => {
      // The debounce on updatePartsPartitions means that some created placeholders
      // might still be considered placeholders hereafter, thus the need to make sure
      // that the work.serieOrdinalNum is above nextPlaceholderOrdinalToCreate
      return workIsPlaceholder(work) && work.serieOrdinalNum > nextPlaceholderOrdinalToCreate
    })
    if (nextPlaceholder) {
      // Trigger SerieCleanupWork's call to createPlaceholder
      nextPlaceholderOrdinalToCreate = nextPlaceholder.serieOrdinalNum
    } else {
      // End of queue: cleanup
      creatingAllPlaceholder = false
      nextPlaceholderOrdinalToCreate = 0
    }
  }

  function onCreatedPlaceholder (e) {
    const createdWork = e.detail as SerializedEntity
    allSerieParts = [ ...allSerieParts, createdWork ]
    if (creatingAllPlaceholder) createNextPlaceholder()
  }

  function changeEditionWork ({ edition, originWork, targetWork }: { edition: SerializedEntity, originWork: SerializedEntity | WorkWithEditions, targetWork: WorkWithEditions }) {
    if ('editions' in originWork) {
      originWork.editions = originWork.editions.filter(entity => entity.uri !== edition.uri)
    } else {
      isolatedEditions = isolatedEditions.filter(entity => entity.uri !== edition.uri)
    }
    targetWork.editions = [ ...targetWork.editions, edition ]
    allSerieParts = allSerieParts
  }

  function onChangeEditionWork (e) {
    const { edition, originWork, targetWork } = e.detail
    onChangeEditionWork({ edition, originWork, targetWork })
  }

  async function addToSerie (work: SerializedEntity) {
    allSerieParts = [ ...allSerieParts, work ]
    partsSuggestions = partsSuggestions.filter(part => part.uri !== work.uri)
    await addClaim(work, 'wdt:P179', serie.uri as EntityValue)
  }

  $: onChange(allSerieParts, partsNumber, lazyUpdatePartsPartitions)
  $: setQueryParameter('authors', showAuthors)
  $: setQueryParameter('editions', showEditions)
  $: setQueryParameter('descriptions', showDescriptions)
  $: setQueryParameter('large', largeMode)
</script>

<Flash state={flash} />
{#await waitForParts}
  <FullScreenLoader />
{:then}
  <div class="serie-cleanup" class:show-large={largeMode}>
    <SerieCleanupControls
      bind:serie
      bind:showAuthors
      bind:showEditions
      bind:showDescriptions
      bind:largeMode
      bind:placeholderCounter
      bind:partsNumber
      bind:titlePattern
      {maxOrdinal}
      worksWithOrdinalLength={worksWithOrdinal?.length || 0}
      {creatingAllPlaceholder}
      on:createPlaceholders={createPlaceholders}
    />

    {#if worksInConflicts.length > 0}
      <div class="works-in-conflicts">
        <h3 class="section-label">{I18n('parts with ordinal conflicts')}</h3>
        <ul class="works-container">
          {#each worksInConflicts as work (work.uri)}
            <SerieCleanupWork
              {work}
              {serie}
              {availableOrdinals}
              {showAuthors}
              {showEditions}
              {showDescriptions}
              {largeMode}
              {allSerieAuthors}
              {allSerieParts}
              on:merged={onWorkMerged}
              on:changeEditionWork={onChangeEditionWork}
            />
          {/each}
        </ul>
      </div>
    {/if}
    {#if isNonEmptyArray(isolatedEditions)}
      <div class="isolated-editions-wrapper">
        <h3 class="section-label">{I18n('isolated editions')}</h3>
        <div class="isolated-editions">
          <ul>
            <!-- Keeping a consistent sorting function so that rolling back an edition -->
            <!-- puts it back at the same spot -->
            {#each isolatedEditions.sort(sortByLabel) as edition}
              <SerieCleanupEdition
                {edition}
                work={serie}
                {allSerieParts}
                {largeMode}
                on:changeEditionWork={e => changeEditionWork({ edition, originWork: serie, targetWork: e.detail })}
              />
            {/each}
          </ul>
        </div>
      </div>
    {/if}
    <div class="works-without-ordinal">
      <h3 class="section-label">{I18n('parts without ordinal')}</h3>
      <ul class="works-container">
        {#each worksWithoutOrdinal as work (work.uri)}
          <SerieCleanupWork
            bind:work
            {serie}
            {availableOrdinals}
            {showAuthors}
            {showEditions}
            {showDescriptions}
            {largeMode}
            {allSerieAuthors}
            {allSerieParts}
            on:merged={onWorkMerged}
            on:selectOrdinal={updatePartsPartitions}
            on:changeEditionWork={onChangeEditionWork}
          />
        {/each}
      </ul>
    </div>
    <div class="works-with-ordinal">
      <h3 class="section-label">{I18n('parts with ordinal')}</h3>
      <ul class="works-container">
        {#each worksWithOrdinal as work ('uri' in work ? work.uri : work.serieOrdinalNum)}
          <SerieCleanupWork
            {work}
            {serie}
            {availableOrdinals}
            {showAuthors}
            {showEditions}
            {showDescriptions}
            {largeMode}
            {allSerieAuthors}
            placeholderTitle={getSeriePlaceholderTitle(serie.label, titlePattern, titleKey, numberKey, work.serieOrdinalNum)}
            bind:selectedLang
            {allSerieParts}
            on:merged={onWorkMerged}
            on:createdPlaceholder={onCreatedPlaceholder}
            bind:nextPlaceholderOrdinalToCreate
            on:changeEditionWork={onChangeEditionWork}
          />
        {/each}
      </ul>
    </div>

    <div class="parts-suggestions-wrapper">
      <h3 class="section-label">{I18n('parts suggestions')}</h3>
      <div class="parts-suggestions">
        <ul>
          {#each partsSuggestions as partSuggestion (partSuggestion.uri)}
            <PartSuggestion
              {partSuggestion}
              {serie}
              {allSerieAuthorsByUris}
              {allSerieParts}
              on:merged={onWorkMerged}
              on:add={() => addToSerie(partSuggestion)}
            />
          {/each}
        </ul>
      </div>
    </div>
  </div>
{/await}

<style lang="scss">
  @import '#general/scss/utils';

  .section-label{
    font-size: 1.1em;
    @include sans-serif;
    padding: 0.5em 0 0 1em;
    margin: 0;
  }
  .works-without-ordinal{
    background-color: #ccc;
  }
  .works-in-conflicts{
    background-color: #aaa;
  }

  .works-container{
    @include display-flex(row, baseline, flex-start, wrap);
  }
  .show-large{
    .works-container{
      justify-content: center;
    }
  }
  .isolated-editions-wrapper{
    background-color: lighten(red, 15%);
  }
  .isolated-editions{
    padding: 0.5em;
    @include display-flex(row, flex-start, null, wrap);
    :global(.serie-cleanup-edition){
      margin: 0.5em;
      @include radius;
      width: 20em;
    }
  }
  .parts-suggestions-wrapper{
    background-color: $dark-grey;
    padding-block-end: 0.2em;
    h3{
      color: white;
    }
  }
  .parts-suggestions{
    ul{
      @include display-flex(row, null, null, wrap);
    }
  }
</style>
