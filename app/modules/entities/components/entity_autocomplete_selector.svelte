<script>
  import { autofocus } from '#lib/components/actions/autofocus'
  import { createEventDispatcher } from 'svelte'
  import Spinner from '#general/components/spinner.svelte'
  import EntitySuggestion from './entity_suggestion.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/handlebars_helpers/icons'
  import getActionKey from '#lib/get_action_key'
  import typeSearch from '#entities/lib/search/type_search'
  import { createByProperty } from '#entities/lib/create_entities'

  export let searchTypes, currentEntityUri, currentEntityLabel, allowEntityCreation = false, createdEntityTypeName, createOnWikidata, relationSubjectEntity, relationProperty, displaySuggestionType

  const dispatch = createEventDispatcher()

  let input

  let suggestions = []
  let showSuggestions = false

  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      close()
      dispatch('close')
    } else if (key === 'enter') {
      if (suggestions[highlightedIndex]) {
        dispatch('select', suggestions[highlightedIndex].uri)
      }
    } else if (key === 'down') {
      highlightedIndex = highlightedIndex + 1
      e.preventDefault()
    } else if (key === 'up') {
      highlightedIndex = highlightedIndex - 1
      e.preventDefault()
    } else {
      lazySearch()
    }
  }

  let lastSearch, searchText, waitForSearch
  let limit = 10, offset = 0, fetching = false, canFetchMore = true
  // TODO: detect uris and get the corresponding entities
  async function search (options = {}) {
    const { fetchMore = false } = options
    try {
      searchText = input.value
      if (searchText.length === 0) return
      if (searchText === lastSearch) {
        if (fetching || !fetchMore || !canFetchMore) return
        offset += limit
        limit += 10
      } else {
        limit = 10
        offset = 0
        highlightedIndex = 0
        suggestions = []
        canFetchMore = true
      }
      lastSearch = searchText
      waitForSearch = typeSearch(searchTypes, searchText, limit, offset)
      showSuggestions = true
      fetching = true
      const res = await waitForSearch
      if (searchText === lastSearch) {
        suggestions = suggestions.concat(res.results)
        showSuggestions = true
        canFetchMore = res.continue != null
      }
    } catch (err) {
      dispatch('error', err)
    } finally {
      fetching = false
    }
  }

  const lazySearch = _.debounce(search, 200)

  // TODO: fix scroll
  function onSuggestionsScroll (e) {
    const { scrollTop, scrollTopMax } = e.currentTarget
    if (scrollTopMax < 100) return
    if (scrollTop + 100 > scrollTopMax) search({ fetchMore: true })
  }

  let highlightedIndex = 0

  $: if (highlightedIndex < 0) highlightedIndex = 0

  async function create () {
    try {
      const createdEntityModel = await createByProperty({
        relationSubjectEntity,
        property: relationProperty,
        name: searchText,
        createOnWikidata,
      })
      dispatch('select', createdEntityModel.get('uri'))
    } catch (err) {
      dispatch('error', err)
    }
  }

  function close () {
    showSuggestions = false
  }
</script>

<div class="input-group">
  <div class="input-wrapper">
    <input type="text"
      value={currentEntityLabel || ''}
      on:keyup={onInputKeyup}
      bind:this={input}
      use:autofocus
    >
    {#if currentEntityUri}
      <span class="uri">{currentEntityUri}</span>
    {/if}
  </div>
  {#if showSuggestions}
    <div class="autocomplete">
      <div class="suggestions-wrapper" on:scroll={onSuggestionsScroll}>
        <ul class="suggestions">
          {#each suggestions as suggestion, i}
            <EntitySuggestion
              {suggestion}
              {displaySuggestionType}
              highlight={i === highlightedIndex}
              on:select={() => dispatch('select', suggestion.uri)}
            />
          {/each}
        </ul>
        {#if fetching}
          <div class="spinner-wrapper"><Spinner /></div>
        {:else if suggestions.length === 0}
          <p class="no-result">{i18n('no result')}</p>
        {/if}
      </div>
      <div class="controls">
        <button class="close" on:click={close}>
          {@html icon('close')}
          {I18n('close')}
        </button>
        {#if allowEntityCreation && searchText.length > 0}
          <button
            class="create"
            on:click={create}
          >
            {@html icon('plus')}
            {I18n(`create a new ${createdEntityTypeName}`)}: "{searchText}"
          </button>
        {/if}
      </div>
    </div>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .input-group{
    flex: 1;
    font-weight: normal;
    position: relative;
    margin-right: 0.5em;
    width: 100%;
  }
  .input-wrapper{
    width: 100%;
    position: relative;
    input{
      flex: 1;
      height: 100%;
      font-weight: normal;
      padding: 0.5em 0.5em 0.8em 0.5em;
      margin-bottom: 0.1em;
    }
    .uri{
      position: absolute;
      right: 0.5em;
      bottom: 0.2em;
    }
  }
  .autocomplete{
    /*Large screens*/
    @media screen and (min-width: $very-small-screen) {
      position: absolute;
      top: 100%;
      left: -1px;
      right: -1px;
      z-index: 1;
    }
    /*Small screens*/
    @media screen and (max-width: $small-screen) {
      width: 100%;
    }
    background-color: white;
    @include display-flex(column, center, center);
    @include shy-border(0.9);
    overflow: hidden;
  }
  .suggestions-wrapper{
    position: relative;
    max-height: 10em;
    overflow: auto;
    align-self: stretch;
  }
  .spinner-wrapper{
    @include display-flex(row, center, center);
  }
  .controls{
    @include display-flex(row, center, space-between);
    width: 100%;
    background-color: #ddd;
    button{
      font-weight: normal;
      margin: 0.5em;
      padding: 0.5em;
      white-space: nowrap;
    }
  }
  .close{
    @include bg-hover($light-grey);
    color: #333;
  }
  .create{
    margin-left: auto;
    color: white;
    @include bg-hover($success-color);
    overflow: hidden;
    text-overflow: ellipsis;
  }
  .uri{
    font-size: 0.7rem;
    font-family: sans-serif;
    color: #888;
  }
  .no-result{
    text-align: center;
  }
</style>
