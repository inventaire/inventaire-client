<script>
  import { autofocus } from '#lib/components/actions/autofocus'
  import { createEventDispatcher } from 'svelte'
  import Spinner from '#general/components/spinner.svelte'
  import EntitySuggestion from './entity_suggestion.svelte'
  import properties from '#entities/lib/properties'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/handlebars_helpers/icons'
  import getActionKey from '#lib/get_action_key'
  import typeSearch from '#entities/lib/search/type_search'
  import { createByProperty } from '#entities/lib/create_entities'

  export let currentValue, property, valueLabel, entity

  const dispatch = createEventDispatcher()

  let input

  let suggestions = []
  let showSuggestions = false
  const { searchType, allowEntityCreation, entityTypeName } = properties[property]
  const { uri } = entity

  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      dispatch('close')
    } else if (key === 'enter') {
      dispatch('save', suggestions[highlightedIndex].uri)
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
  async function search () {
    try {
      searchText = input.value
      if (searchText.length === 0 || searchText === lastSearch) return
      lastSearch = searchText
      waitForSearch = typeSearch(searchType, input.value, 20, 0)
      showSuggestions = true
      const res = await waitForSearch
      if (searchText === lastSearch) {
        suggestions = res
        showSuggestions = true
        highlightedIndex = 0
      }
    } catch (err) {
      dispatch('error', err)
    }
  }

  const lazySearch = _.debounce(search, 200)

  let highlightedIndex = 0

  $: {
    if (highlightedIndex < 0) highlightedIndex = 0
  }

  async function create () {
    try {
      const createdEntityModel = await createByProperty({
        property,
        name: searchText,
        relationEntity: entity,
        createOnWikidata: uri.startsWith('wd:')
      })
      dispatch('save', createdEntityModel.get('uri'))
    } catch (err) {
      dispatch('error', err)
    }
  }
</script>

<div class="input-wrapper">
  <input type="text"
    value={valueLabel || ''}
    on:keyup={onInputKeyup}
    bind:this={input}
    use:autofocus
  >
  {#if currentValue}
    <span class="uri">{currentValue}</span>
  {/if}
  {#if showSuggestions}
    <div class="autocomplete">
      {#await waitForSearch}
        <Spinner />
      {:then}
        {#if suggestions.length > 0}
          <ul class="suggestions">
            {#each suggestions as suggestion, i (suggestion.uri)}
              <EntitySuggestion
                {suggestion}
                highlight={i === highlightedIndex}
                on:select={() => dispatch('save', suggestion.uri)}
              />
            {/each}
          </ul>
        {:else}
          <p class="no-result">{i18n('no result')}</p>
        {/if}
        <div class="controls">
          <button
            class="close"
            on:click={() => showSuggestions = false}
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
              {I18n(`create a new ${entityTypeName}`)}: "{searchText}"
            </button>
          {/if}
        </div>
      {/await}
    </div>
  {/if}
</div>


<style lang="scss">
  @import '#general/scss/utils';
  .input-wrapper{
    flex: 1;
    height: 3em;
    font-weight: normal;
    position: relative;
    margin-right: 0.5em;
    input{
      flex: 1;
      height: 100%;
      font-weight: normal;
      padding: 1.2em 0.5em 1.8em 0.5em;
      margin-bottom: 0.1em;
    }
    .uri{
      position: absolute;
      right: 0.5em;
      bottom: 0.2em;
    }
  }
  .autocomplete{
    position: absolute;
    top: 100%;
    left: -1px;
    right: -1px;
    background-color: white;
    @include display-flex(column, center, center);
    @include shy-border(0.9);
  }
  .suggestions{
    max-height: 10em;
    overflow: auto;
    position: relative;
    align-self: stretch;
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
