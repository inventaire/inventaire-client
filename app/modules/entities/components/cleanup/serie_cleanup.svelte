<script lang="ts">
  import { uniq, values, without } from 'underscore'
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { onChange } from '#app/lib/svelte/svelte'
  import FullScreenLoader from '#components/full_screen_loader.svelte'
  import PartSuggestion from '#entities/components/cleanup/part_suggestion.svelte'
  import { addClaim, getEntitiesBasicInfoByUris, type SerializedEntitiesByUris, type SerializedEntity } from '#entities/lib/entities'
  import { getSerieOrWorkExtendedAuthorsUris, getSerieParts } from '#entities/lib/types/serie_alt'
  import { fillGaps, getSeriePlaceholderTitle, type SeriePartPlaceholder } from '#entities/views/cleanup/lib/fill_gaps'
  import { spreadParts } from '#entities/views/cleanup/lib/spread_part'
  import type { EntityValue } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'
  import { getPartsSuggestions } from '../../views/cleanup/lib/get_parts_suggestions'
  import { getIsolatedEditions, getPossibleOrdinals, sortByLabel, workIsPlaceholder, type WorkWithEditions } from './lib/serie_cleanup_helpers'
  import SerieCleanupControls from './serie_cleanup_controls.svelte'
  import SerieCleanupWork from './serie_cleanup_work.svelte'
  import type { WorkSuggestion } from '../../views/cleanup/lib/add_pertinance_score'

  export let serie: SerializedEntity

  let worksWithOrdinal: (SerializedEntity | SeriePartPlaceholder)[] = []
  let worksWithoutOrdinal: SerializedEntity[] = []
  let worksInConflicts: SerializedEntity[] = []
  let allExistingParts: SerializedEntity[] = []
  let partsSuggestions: WorkSuggestion[] = []
  let maxOrdinal = 0
  let placeholderCounter = 0
  let partsNumber = 0
  const titleKey = `{${i18n('title')}}`
  const numberKey = `{${i18n('number')}}`
  let titlePattern = `${titleKey} - ${I18n('volume')} ${numberKey}`
  let selectedLang = app.user.lang

  const states = app.request('querystring:get:all')
  let showAuthors = states.authors === 'true'
  let showEditions = states.editions === 'true'
  let showDescriptions = states.descriptions === 'true'
  let largeMode = states.large === 'true'

  const serieAuthorsUris = getSerieOrWorkExtendedAuthorsUris(serie)
  let allSerieAuthors: SerializedEntity[]
  let allSerieAuthorsByUris: SerializedEntitiesByUris

  let flash
  const waitForParts = getSerieParts(serie, { refresh: true, fetchAll: true })
    .then(async parts => {
      allExistingParts = parts
      const allWorkAuthorsUris = parts.map(work => getSerieOrWorkExtendedAuthorsUris(work)).flat()
      const allSerieAuthorsUris = uniq(serieAuthorsUris.concat(allWorkAuthorsUris))
      allSerieAuthorsByUris = await getEntitiesBasicInfoByUris(allSerieAuthorsUris)
      allSerieAuthors = values(allSerieAuthorsByUris)
    })
    .catch(err => flash = err)

  waitForParts.then(async () => {
    partsSuggestions = await getPartsSuggestions(serie, allExistingParts, serieAuthorsUris)
  })

  let possibleOrdinals: number[] = []

  function updatePartsPartitions () {
    ;({ worksWithOrdinal, worksWithoutOrdinal, worksInConflicts, maxOrdinal } = spreadParts(allExistingParts))
    partsNumber = Math.max(maxOrdinal, partsNumber)
    worksWithOrdinal = fillGaps(worksWithOrdinal, serie.uri, serie.label, titlePattern, titleKey, numberKey)
    possibleOrdinals = getPossibleOrdinals(worksWithOrdinal)
  }

  const creatingPlaceholders = false
  function createPlaceholders () {
    alert('TODO: implement createPlaceholders')
  }

  function setQueryParameter (name: string, bool: boolean) {
    if (bool) app.request('querystring:set', name, bool)
    else app.request('querystring:remove', name)
  }

  function onWorkMerged (e) {
    const { from } = e.detail
    allExistingParts = without(allExistingParts, from)
  }

  function onCreatedPlaceholder (e) {
    const createdWork = e.detail as SerializedEntity
    allExistingParts = [ ...allExistingParts, createdWork ]
  }

  async function addToSerie (work: SerializedEntity) {
    allExistingParts = [ ...allExistingParts, work ]
    partsSuggestions = partsSuggestions.filter(part => part.uri !== work.uri)
    await addClaim(work, 'wdt:P179', serie.uri as EntityValue)
  }

  $: onChange(allExistingParts, updatePartsPartitions)
  $: placeholderCounter = worksWithOrdinal.filter(work => 'isPlacehoder' in work).length
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
      on:createPlaceholders={createPlaceholders}
      {creatingPlaceholders}
    />

    {#if worksInConflicts.length > 0}
      <div class="works-in-conflicts">
        <h3 class="section-label">{I18n('parts with ordinal conflicts')}</h3>
        <ul class="works-container">
          {#each worksInConflicts as work (work.uri)}
            <SerieCleanupWork
              {work}
              {serie}
              {possibleOrdinals}
              {showAuthors}
              {showEditions}
              {showDescriptions}
              {largeMode}
              {allSerieAuthors}
              allSerieParts={allExistingParts}
              on:merged={onWorkMerged}
            />
          {/each}
        </ul>
      </div>
    {/if}
    <div class="isolated-editions-wrapper hidden">
      <h3 class="section-label">{I18n('isolated editions')}'</h3>
      <div class="isolated-editions" />
    </div>
    <div class="works-without-ordinal">
      <h3 class="section-label">{I18n('parts without ordinal')}</h3>
      <ul class="works-container">
        {#each worksWithoutOrdinal as work (work.uri)}
          <SerieCleanupWork
            bind:work
            {serie}
            {possibleOrdinals}
            {showAuthors}
            {showEditions}
            {showDescriptions}
            {largeMode}
            {allSerieAuthors}
            allSerieParts={allExistingParts}
            on:merged={onWorkMerged}
            on:selectOrdinal={updatePartsPartitions}
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
            {possibleOrdinals}
            {showAuthors}
            {showEditions}
            {showDescriptions}
            {largeMode}
            {allSerieAuthors}
            placeholderTitle={getSeriePlaceholderTitle(serie.label, titlePattern, titleKey, numberKey, work.serieOrdinalNum)}
            bind:selectedLang
            allSerieParts={allExistingParts}
            on:merged={onWorkMerged}
            on:createdPlaceholder={onCreatedPlaceholder}
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
              allSerieParts={allExistingParts}
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
    ul{
      @include display-flex(row, flex-start, null, wrap);
    }
    .serie-cleanup-edition{
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
