<script>
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import { autofocus } from 'lib/components/actions/autofocus'
  import { i18n } from 'modules/user/lib/i18n'
  import getActionKey from 'lib/get_action_key'
  import Flash from 'lib/components/flash.svelte'
  import preq from 'lib/preq'
  import { createEventDispatcher } from 'svelte'
  import typeSearch from 'modules/entities/lib/search/type_search'
  import properties from 'modules/entities/lib/properties'
  import EntitySuggestion from './entity_suggestion.svelte'
  import { getBasicInfoByUri } from 'modules/entities/lib/entities'
  import Spinner from 'modules/general/components/spinner.svelte'
  import { imgSrc } from 'lib/handlebars_helpers/images'

  export let uri, property, value

  let editMode = (value == null)
  let oldValue = value
  let currentValue = value
  let input, flash, label, description, image, waitingForInfo
  let suggestions = []
  let showSuggestions = true
  const { searchType } = properties[property]
  const dispatch = createEventDispatcher()

  $: {
    if (currentValue) {
      waitingForInfo = getBasicInfoByUri(currentValue)
        .then(data => {
          label = data.label
          description = data.description
          image = data.image
        })
    }
  }

  function showEditMode () { editMode = true }
  function closeEditMode () {
    editMode = false
    flash = null
    if (value === null) dispatch('remove')
  }
  async function save (value) {
    editMode = false
    currentValue = value
    if (oldValue === currentValue) return
    try {
      await preq.put(app.API.entities.claims.update, {
        uri,
        property,
        'old-value': oldValue,
        'new-value': value,
      })
      oldValue = currentValue
      currentValue = value
    } catch (err) {
      editMode = true
      showSuggestions = false
      flash = err
    }
  }
  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') closeEditMode()
    else if (e.ctrlKey && key === 'enter') save()
    else search()
  }

  async function search () {
    const searchText = input.value
    if (searchText.length === 0) return
    suggestions = await typeSearch(searchType, input.value, 20, 0)
    showSuggestions = true
  }

  async function remove () {
    dispatch('remove')
    await save(null)
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
        {#if showSuggestions && suggestions.length > 0}
          <div class="autocomplete">
            <ul class="suggestions">
              {#each suggestions as suggestion (suggestion.uri)}
                <EntitySuggestion
                  {suggestion}
                  on:select={() => save(suggestion.uri)}
                />
              {/each}
            </ul>
            <button
              class="close"
              on:click={() => showSuggestions = false}
            >
              {i18n('close')}
            </button>
          </div>
        {/if}
      </div>
      <EditModeButtons
        on:save={save}
        on:cancel={closeEditMode}
        on:delete={remove}
      />
    {:else}
      <button class="value-display" on:click={showEditMode} title="{i18n('edit')}">
        {#await waitingForInfo}
          <Spinner />
        {:then}
          <div
            class="image"
            style:background-image={image ? `url(${imgSrc(image.url, 64, 64)})` : ''}
          >
          </div>
          <div>
            <span class="label">{label}</span>
            <div class="bottom">
              {#if description}<span class="description">{description}</span>{/if}
              <!-- TODO: recover tooltip -->
              {#if currentValue}<span class="uri">{currentValue}</span>{/if}
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
    margin-top: -3px;
    @include shy-border(0.9);
  }
  .suggestions{
    max-height: 10em;
    overflow: auto;
  }
  .close{
    width: 100%;
    display: block;
    text-align: center;
    font-weight: normal;
    @include bg-hover(#eaeaea);
    color: #333;
    margin: 0;
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
</style>
