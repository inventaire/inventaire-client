<script lang="ts">
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { i18n, I18n } from '#user/lib/i18n'
  import type { WorkSuggestion } from '../../views/cleanup/lib/add_pertinance_score'
  // import { entityClaim } from './HELPERS_PATH.js'

  export let partSuggestion: WorkSuggestion

  const { uri, image, label, pathname, labelMatch, authorMatch } = partSuggestion

  const isWikidataEntity = 'isWikidataEntity' in partSuggestion && partSuggestion.isWikidataEntity

  let serieNeedsToBeMovedToWikidata
</script>

<li class="serie-cleanup-part-suggestion" class:label-match={labelMatch} class:author-match={authorMatch}>
  <div>
    {#if image.url}<img src={imgSrc(image.url, 100)} alt={label} loading="lazy">{/if}
  </div>
  <a class="showEntity link" href={pathname}>{label}</a>
  <p class="uri">{uri}</p>
  <p class="claims">
    <!-- {entityClaim(claims 'wdt:P50' true)} -->
    <!-- {entityClaim(claims 'wdt:P179' true)} -->
  </p>

  <div>
    {#if serieNeedsToBeMovedToWikidata}
      <button class="add disabled" title={i18n('move the series to Wikidata to be able to add this work')}>
        {@html icon('plus')}
        {I18n('add to the series')}
      </button>
    {:else}
      <button class="add">{@html icon('plus')} {I18n('add to the series')}</button>
    {/if}
  </div>

  {#if !isWikidataEntity}
    <!-- {PARTIAL 'entities:cleanup:work_picker' this} -->
  {/if}
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
    margin-block-start: auto;
    &.disabled{
      cursor: not-allowed;
    }
  }
  .showWorkPicker, .workPicker{
    display: block;
    margin-block-start: 1em;
  }
  .validate{
    display: block;
  }
</style>
