<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import Flash from '#app/lib/components/flash.svelte'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import Spinner from '#components/spinner.svelte'
  import ClaimsInfobox from '#entities/components/layouts/claims_infobox.svelte'
  import { mergeEntities } from '#entities/lib/editor/merge_entities'
  import type { SerializedEntitiesByUris, SerializedEntity } from '#entities/lib/entities'
  import { authorProperties } from '#entities/lib/properties'
  import { I18n } from '#user/lib/i18n'
  import WorkPicker from './work_picker.svelte'
  import type { WorkSuggestion } from './lib/add_relevance_score'

  export let partSuggestion: WorkSuggestion
  export let serie: SerializedEntity
  export let allSerieAuthorsByUris: SerializedEntitiesByUris
  export let allSerieParts: SerializedEntity[]

  const { uri, image, label, pathname, labelMatch, authorMatch, claims } = partSuggestion

  const isWikidataEntity = 'isWikidataEntity' in partSuggestion && partSuggestion.isWikidataEntity

  const serieNeedsToBeMovedToWikidata = isWikidataEntity && !serie.isWikidataEntity

  const allowlistedProperties = authorProperties.slice(0)

  let showMergeWorkPicker = false
  const dispatch = createEventDispatcher()

  let merging, flash
  async function merge (selectedWork: SerializedEntity) {
    try {
      merging = true
      await mergeEntities(partSuggestion.uri, selectedWork.uri)
      dispatch('merged', { from: partSuggestion, to: selectedWork })
    } catch (err) {
      merging = false
      flash = err
    }
  }
</script>

<li class="serie-cleanup-part-suggestion" class:label-match={labelMatch} class:author-match={authorMatch}>
  <div>
    {#if image.url}<img src={imgSrc(image.url, 100)} alt={label} loading="lazy" />{/if}
  </div>
  <a class="showEntity link" href={pathname}>{label}</a>
  <p class="uri">{uri}</p>
  <p class="claims">
    <ClaimsInfobox
      {allowlistedProperties}
      {claims}
      relatedEntities={allSerieAuthorsByUris}
      entityType="work"
    />
  </p>

  {#if merging}
    <Spinner />
  {:else}
    <div>
      {#if serieNeedsToBeMovedToWikidata}
        <button class="add" disabled={true} title={I18n('move the series to Wikidata to be able to add this work')}>
          {@html icon('plus')}
          {I18n('add to the series')}
        </button>
      {:else}
        <button class="add" on:click={() => dispatch('add')}>
          {@html icon('plus')} {I18n('add to the series')}
        </button>
      {/if}
    </div>

    {#if !isWikidataEntity}
      {#if showMergeWorkPicker}
        <WorkPicker
          work={partSuggestion}
          {allSerieParts}
          validateLabel="merge"
          on:selectWork={e => merge(e.detail)}
          on:close={() => showMergeWorkPicker = false}
        />
      {:else}
        <button
          class="toggle-merge-work-picker"
          title={I18n('merge')}
          on:click={() => showMergeWorkPicker = !showMergeWorkPicker}
        >
          {@html icon('compress')}
          {I18n('merge')}
        </button>
      {/if}
    {/if}
  {/if}

  <Flash state={flash} />
</li>

<style lang="scss">
  @import '#general/scss/utils';

  .serie-cleanup-part-suggestion{
    @include radius;
    padding: 1em;
    margin: 1em;
    background-color: #eee;
    text-align: center;
    max-width: 18em;
    @include display-flex(column);
    &.label-match{
      background-color: #0bb;
      a.showEntity, p.uri{
        color: white !important;
      }
    }
    &.author-match.label-match{
      background-color: #0b0;
    }
  }
  img{
    cursor: zoom-in;
  }
  .claims{
    margin-block-end: auto;
  }
  .add{
    @include tiny-button($grey);
    display: block;
    margin: 0 auto;
    &:disabled{
      cursor: not-allowed;
    }
  }
  .toggle-merge-work-picker{
    display: block;
    margin-block-start: 1em;
  }
</style>
