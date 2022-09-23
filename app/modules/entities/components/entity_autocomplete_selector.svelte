<script>
  import { autofocus as autofocusFn } from '#lib/components/actions/autofocus'
  import { createEventDispatcher } from 'svelte'
  import Spinner from '#general/components/spinner.svelte'
  import EntitySuggestion from './entity_suggestion.svelte'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/handlebars_helpers/icons'
  import getActionKey from '#lib/get_action_key'
  import typeSearch from '#entities/lib/search/type_search'
  import { createByProperty } from '#entities/lib/create_entities'
  import { getDefaultSuggestions } from '#entities/components/editor/lib/suggestions/get_suggestions_per_properties'
  import { wait } from '#lib/promises'

  export let searchTypes
  export let currentEntityUri
  export let currentEntityLabel = ''
  export let placeholder
  export let allowEntityCreation = false
  export let showDefaultSuggestions = true
  export let createdEntityTypeName
  export let createOnWikidata
  export let relationSubjectEntity
  export let relationProperty
  export let displaySuggestionType = false
  export let autofocus = true
  export let showSuggestions = false

  const dispatch = createEventDispatcher()

  let input

  let suggestions = []
  let scrollableElement

  function onInputKeydown (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      close()
      dispatch('close')
    } else if (key === 'enter') {
      if (suggestions[highlightedIndex]) {
        dispatch('select', suggestions[highlightedIndex])
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

  let lastSearch, waitForSearch
  let searchText = currentEntityLabel || ''
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
        suggestions = suggestions.concat(getNewSuggestions(res.results))
        showSuggestions = true
        canFetchMore = res.continue != null
      }
    } catch (err) {
      showSuggestions = false
      dispatch('error', err)
    } finally {
      fetching = false
    }
  }

  function getNewSuggestions (newSuggestions) {
    const currentSuggestionsUris = new Set(_.map(suggestions, 'uri'))
    return newSuggestions.filter(suggestion => !currentSuggestionsUris.has(suggestion.uri))
  }

  const lazySearch = _.debounce(search, 200)

  if (currentEntityLabel && autofocus) lazySearch()

  function onFocus () {
    lazySearch()
  }

  async function onBlur (e) {
    // If the focus is lost because the user clicked on one of the suggestions,
    // let EntitySuggestion 'select' event be acted upon before the component
    // gets destroyed due to `showSuggestions = false`
    // Somehow, waiting for the next tick isn't enough.
    await wait(200)
    showSuggestions = false
  }

  function onSuggestionsScroll (e) {
    const { scrollTop, scrollTopMax } = e.currentTarget
    if (scrollTopMax < 100) return
    if (scrollTop + 100 > scrollTopMax) search({ fetchMore: true })
  }

  let highlightedIndex = 0

  $: {
    const lastIndex = suggestions.length - 1
    if (highlightedIndex < 0) highlightedIndex = 0
    else if (!canFetchMore && highlightedIndex > lastIndex) {
      highlightedIndex = 0
    }
  }

  async function create () {
    try {
      const createdEntityModel = await createByProperty({
        relationSubjectEntity,
        property: relationProperty,
        name: searchText,
        createOnWikidata,
      })
      dispatch('select', createdEntityModel.toJSON())
    } catch (err) {
      dispatch('error', err)
    }
  }

  function close () {
    showSuggestions = false
  }

  let defaultSuggestions
  async function fetchDefaultSuggestions () {
    try {
      showSuggestions = true
      fetching = true
      defaultSuggestions = defaultSuggestions || await getDefaultSuggestions({
        entity: relationSubjectEntity,
        property: relationProperty
      })
      fetching = false
      if (defaultSuggestions && searchText === '') suggestions = defaultSuggestions
    } catch (err) {
      showSuggestions = false
      dispatch('error', err)
    }
  }

  $: if (showDefaultSuggestions && searchText === '') fetchDefaultSuggestions()
</script>

<div class="input-group">
  <div class="input-wrapper">
    <input type="text"
      on:click|stopPropagation
      bind:value={currentEntityLabel}
      on:keydown={onInputKeydown}
      on:focus={onFocus}
      on:blur={onBlur}
      bind:this={input}
      use:autofocusFn={{ disabled: autofocus !== true }}
      class:has-entity-uri={currentEntityUri != null}
      title={I18n('search for an entity')}
      placeholder={placeholder}
    >
    {#if currentEntityUri}
      <span class="uri">{currentEntityUri}</span>
    {/if}
  </div>
  {#if showSuggestions && (searchText !== '' || suggestions.length > 0)}
    <div class="autocomplete">
      <div class="suggestions-wrapper" on:scroll={onSuggestionsScroll} bind:this={scrollableElement}>
        <ul class="suggestions">
          {#each suggestions as suggestion, i (suggestion.uri)}
            <EntitySuggestion
              {suggestion}
              {displaySuggestionType}
              {scrollableElement}
              highlight={i === highlightedIndex}
              on:select={() => dispatch('select', suggestion)}
            />
          {/each}
        </ul>
        {#await (waitForSearch || defaultSuggestions)}
          <div class="spinner-wrapper"><Spinner /></div>
        {:then}
          {#if suggestions.length === 0}
            <p class="no-result">{i18n('no result')}</p>
          {/if}
        {/await}
      </div>
      <div class="controls">
        <button class="close"
          on:click|stopPropagation={close}
        >
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
      margin-bottom: 0.1em;
      @include transition(padding, 0.2s);
      &.has-entity-uri{
        padding: 0.5em 0.5em 0.8em 0.5em;
      }
      &:not(.has-entity-uri){
        padding: 0.5em;
      }
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
    @include shy-border(0.5);
    overflow: hidden;
  }
  .suggestions-wrapper{
    position: relative;
    max-height: 15rem;
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
    padding: 0.5em;
  }
</style>
