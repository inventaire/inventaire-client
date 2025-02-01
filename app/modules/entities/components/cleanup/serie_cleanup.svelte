<script lang="ts">
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { onChange } from '#app/lib/svelte/svelte'
  import FullScreenLoader from '#components/full_screen_loader.svelte'
  import PartSuggestion from '#entities/components/cleanup/part_suggestion.svelte'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { getSerieOrWorkExtendedAuthorsUris, getSerieParts } from '#entities/lib/types/serie_alt'
  import { fillGaps, type SeriePartPlaceholder } from '#entities/views/cleanup/lib/fill_gaps'
  import { spreadParts } from '#entities/views/cleanup/lib/spread_part'
  import type { EntityUri } from '#server/types/entity'
  import { i18n, I18n } from '#user/lib/i18n'
  import { getPartsSuggestions } from '../../views/cleanup/lib/get_parts_suggestions'
  import SerieCleanupControls from './serie_cleanup_controls.svelte'
  import SerieCleanupWork from './serie_cleanup_work.svelte'
  import type { WorkSuggestion } from '../../views/cleanup/lib/add_pertinance_score'

  export let entity: SerializedEntity

  let worksWithOrdinal: (SerializedEntity | SeriePartPlaceholder)[] = []
  let worksWithoutOrdinal: SerializedEntity[] = []
  let worksInConflicts: SerializedEntity[] = []
  let allExistingParts: SerializedEntity[] = []
  let partsSuggestions: WorkSuggestion[] = []

  const allAuthorsUris = getSerieOrWorkExtendedAuthorsUris(entity)

  let maxOrdinal = 0
  let possibleOrdinals: number[] = []
  let placeholderCounter = 0
  let partsNumber = 0
  let titleKey = `{${i18n('title')}}`
  let numberKey = `{${i18n('number')}}`
  let titlePattern = `${titleKey} - ${I18n('volume')} ${numberKey}`

  const states = app.request('querystring:get:all')
  let showAuthors = states.authors === 'true'
  let showEditions = states.editions === 'true'
  let showDescriptions = states.descriptions === 'true'
  let largeMode = states.large === 'true'

  let flash
  const waitForParts = getSerieParts(entity, { refresh: true, fetchAll: true })
    .then(parts => { allExistingParts = parts })
    .catch(err => flash = err)

  waitForParts.then(async () => {
    partsSuggestions = await getPartsSuggestions(entity, allExistingParts, allAuthorsUris)
    console.log('🚀 ~ file: serie_cleanup.svelte ~ line', 49, 'waitForParts.then ~ ', { partsSuggestions })
  })

  function updatePartsPartitions () {
    ;({ worksWithOrdinal, worksWithoutOrdinal, worksInConflicts, maxOrdinal } = spreadParts(allExistingParts))
    partsNumber = Math.max(maxOrdinal, partsNumber)
    worksWithOrdinal = fillGaps(worksWithOrdinal, entity.uri, entity.label, titlePattern, titleKey, numberKey)
  }

  let creatingPlaceholders = false
  function createPlaceholders () {
    alert('TODO: implement createPlaceholders')
  }

  $: onChange(allExistingParts, updatePartsPartitions)
  $: placeholderCounter = worksWithOrdinal.filter(work => 'isPlacehoder' in work).length
</script>

<Flash state={flash} />
{#await waitForParts}
  <FullScreenLoader />
{:then}
  <div class="serie-cleanup" class:show-large={largeMode}>
    <SerieCleanupControls
      bind:serie={entity}
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
        <h3 class="section-label">{i18n('parts with ordinal conflicts')}</h3>
        <ul class="works-container">
          {#each worksInConflicts as work (work.uri)}
            <SerieCleanupWork
              {work}
              {possibleOrdinals}
              {showAuthors}
              {showEditions}
              {showDescriptions}
              {largeMode}
            />
          {/each}
        </ul>
      </div>
    {/if}
    <div class="isolated-editions-wrapper hidden">
      <h3 class="section-label">{i18n('isolated editions')}'</h3>
      <div class="isolated-editions"></div>
    </div>
    <div class="works-without-ordinal">
      <h3 class="section-label">{i18n('parts without ordinal')}</h3>
      <ul class="works-container">
        {#each worksWithoutOrdinal as work (work.uri)}
          <SerieCleanupWork
            {work}
            {possibleOrdinals}
            {showAuthors}
            {showEditions}
            {showDescriptions}
            {largeMode}
          />
        {/each}
      </ul>
    </div>
    <div class="works-with-ordinal">
      <h3 class="section-label">{i18n('parts with ordinal')}</h3>
      <ul class="works-container">
        {#each worksWithOrdinal as work ('uri' in work ? work.uri : Math.random())}
          <SerieCleanupWork
            {work}
            {possibleOrdinals}
            {showAuthors}
            {showEditions}
            {showDescriptions}
            {largeMode}
          />
        {/each}
      </ul>
    </div>

    <div class="parts-suggestions-wrapper">
      <h3 class="section-label">{i18n('parts suggestions')}</h3>
      <div class="parts-suggestions">
        <ul>
          {#each partsSuggestions as partSuggestion}
            <PartSuggestion {partSuggestion} />
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
    padding: 0.5em 0 0 1em;
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
