<script>
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import { autofocus } from 'lib/components/actions/autofocus'
  import { I18n, i18n } from 'modules/user/lib/i18n'
  import getActionKey from 'lib/get_action_key'
  import Flash from 'lib/components/flash.svelte'
  import preq from 'lib/preq'
  import { createEventDispatcher } from 'svelte'
  import typeSearch from 'modules/entities/lib/search/type_search'
  import properties from 'modules/entities/lib/properties'
  import EntitySuggestion from './entity_suggestion.svelte'
  import { getBasicInfoByUri } from 'modules/entities/lib/entities'
  import Spinner from 'modules/general/components/spinner.svelte'
  import IdentifierWithTooltip from './identifier_with_tooltip.svelte'
  import { imgSrc } from 'lib/handlebars_helpers/images'
  import { icon } from 'lib/utils'
  import { createByProperty } from 'modules/entities/lib/create_entities'

  export let entity, uri, property, value

  let editMode = (value == null)
  let oldValue = value
  let currentValue = value
  let input, flash, waitingForValueEntityBasicInfo, label, description, image
  let suggestions = []
  let showSuggestions = false
  const { searchType, allowEntityCreation, entityTypeName } = properties[property]
  const dispatch = createEventDispatcher()

  $: {
    if (currentValue) {
      waitingForValueEntityBasicInfo = getBasicInfoByUri(currentValue)
        .then(setInfo)
        .catch(err => {
          flash = err
        })
    }
  }

  function setInfo (data) {
    label = data.label
    description = data.description
    image = data.image
  }

  function showEditMode () { editMode = true }
  function closeEditMode () {
    editMode = false
    flash = null
    if (value === null) dispatch('set', null)
  }

  async function save (value) {
    editMode = false
    currentValue = value
    dispatch('set', currentValue)
    if (oldValue === currentValue) return
    try {
      await preq.put(app.API.entities.claims.update, {
        uri,
        property,
        'old-value': oldValue,
        'new-value': value,
      })
      oldValue = currentValue
      dispatch('set', currentValue)
    } catch (err) {
      currentValue = oldValue
      dispatch('set', currentValue)
      editMode = true
      showSuggestions = false
      flash = err
    }
  }
  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      closeEditMode()
    } else if (key === 'enter') {
      save(suggestions[highlightedIndex].uri)
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
      flash = err
    }
  }

  const lazySearch = _.debounce(search, 200)

  let highlightedIndex = 0

  $: {
    if (highlightedIndex < 0) highlightedIndex = 0
  }

  async function remove () {
    await save(null)
  }

  async function create () {
    try {
      const createdEntityModel = await createByProperty({
        property,
        name: searchText,
        relationEntity: entity,
        createOnWikidata: uri.startsWith('wd:')
      })
      await save(createdEntityModel.get('uri'))
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="wrapper">
  <div class="value">
    {#if editMode}
      <div class="input-wrapper">
        <input type="text"
          value={label || ''}
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
                      on:select={() => save(suggestion.uri)}
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
      <EditModeButtons
        showSave={false}
        on:cancel={closeEditMode}
        on:delete={remove}
      />
    {:else}
      <button class="value-display" on:click={showEditMode} title="{i18n('edit')}">
        {#await waitingForValueEntityBasicInfo}
          <Spinner />
        {:then}
          <div
            class="image"
            style:background-image={image ? `url(${imgSrc(image.url, 64, 64)})` : ''}
          >
          </div>
          <div>
            {#if label}<span class="label">{label}</span>{/if}
            <div class="bottom">
              {#if description}<span class="description">{description}</span>{/if}
              {#if currentValue}
                <IdentifierWithTooltip uri={currentValue} />
              {/if}
            </div>
          </div>
        {/await}
      </button>
      <DisplayModeButtons on:edit={showEditMode} />
    {/if}
  </div>

  <Flash bind:state={flash}/>
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .wrapper{
    flex: 1;
  }
  .value{
    @include display-flex(row, center);
    margin-bottom: 1em;
    .input-wrapper, .value-display{
      flex: 1;
      height: 100%;
      font-weight: normal;
    }
    .value-display{
      @include display-flex(row, center, flex-start);
      cursor: pointer;
      text-align: left;
      @include bg-hover(white, 5%);
      user-select: text;
      padding: 0;
    }
  }
  .image{
    width: 3em;
    height: 3em;
    margin-right: 0.5em;
    background-size: cover;
    background-position: center center;
  }
  .input-wrapper{
    position: relative;
    margin-right: 0.5em;
    input{
      padding: 1.5em 1em;
      margin-bottom: 0.1em;
    }
    .uri{
      position: absolute;
      right: 0.5em;
      bottom: 0.2em;
    }
  }
  .bottom{
    padding: 0.5em 0;
  }
  .autocomplete{
    position: absolute;
    top: 100%;
    left: -1px;
    right: -1px;
    background-color: white;
    margin-top: -3px;
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
  .label{
    text-align: left;
  }
  .description{
    color: $grey;
    margin-right: 1em;
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
