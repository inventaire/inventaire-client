<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { findWhere } from 'underscore'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { forceArray, isOpenedOutside, loadInternalLink } from '#app/lib/utils'
  import { serializeResult, urlifyImageHash } from '#search/lib/search_results'
  import { i18n } from '#user/lib/i18n'
  import { resortSearchResultsHistory, searchResultsHistory } from '../lib/search_results_history'

  export let result, highlighted

  result = serializeResult(result)

  const { uri, type, typeAlias, label, description = '', pathname } = result
  const { image } = result

  function addToSearchHistory () {
    if (uri) {
      const pictures = forceArray(image).map(urlifyImageHash.bind(null, type))
      const entry = findWhere($searchResultsHistory, { uri }) || { uri, label, type, pictures, timestamp: 0 }
      entry.timestamp = Date.now()
      $searchResultsHistory = resortSearchResultsHistory($searchResultsHistory.concat([ entry ]))
    }
  }

  const dispatch = createEventDispatcher()

  function loadResult (e) {
    if (!isOpenedOutside(e)) {
      loadInternalLink(e)
      dispatch('resultSelected')
    }
    e.stopPropagation()
  }
</script>

<li class="result" class:highlighted>
  <a
    href={pathname}
    on:click={addToSearchHistory}
    on:click={loadResult}
  >
    <div
      class="image"
      style:background-image={image ? `url(${imgSrc(image, 90)})` : ''}
    />
    <span class="type">{i18n(typeAlias)}</span>
    <span class="label">{label}</span>
    <span class="description">{description}</span>
  </a>
</li>

<style lang="scss">
  @import "#general/scss/utils";
  .result{
    line-height: 1em;
    position: relative;
    // Prevent triggering horizontal scroll because of too long content
    overflow: hidden;
    &:hover{
      background-color: darken($light-grey, 5%);
    }
    &.highlighted{
      background-color: #666;
      .label{
        color: white;
      }
      .type, .description{
        color: #bbb;
      }
    }
  }
  a{
    @include display-flex(row, center, flex-start);
    color: $dark-grey;
  }
  .image, .type, .label, .description{
    margin-inline-end: 0.5em;
    white-space: nowrap;
    flex: 0 0 auto;
  }
  .description{
    flex: 0 1 auto;
    overflow: hidden;
  }
  .image{
    margin-inline-end: 0.3em;
    width: 48px;
    height: 48px;
    background-size: cover;
    background-position: center center;
  }
  .type, .description{
    color: grey;
    font-size: 0.9em;
  }
</style>
