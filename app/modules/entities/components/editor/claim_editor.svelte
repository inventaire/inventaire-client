<script>
  import properties from '#entities/lib/properties'
  import { editors } from '#entities/components/editor/lib/editors'
  import { createEventDispatcher } from 'svelte'
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import getActionKey from '#lib/get_action_key'
  import Flash from '#lib/components/flash.svelte'
  import preq from '#lib/preq'
  import { isComponentEvent } from '#lib/boolean_tests'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { currentEditorKey, isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'
  import Spinner from '#components/spinner.svelte'

  export let entity, property, value, index

  const dispatch = createEventDispatcher()
  const { uri, type } = entity
  const creationMode = uri == null
  const { editorType } = properties[property]
  const { InputComponent, DisplayComponent, showSave } = editors[editorType]
  const fixed = editorType.split('-')[0] === 'fixed'

  let inputValue = value
  let savedValue = value
  let editMode = (inputValue == null)

  let getInputValue, flash, valueLabel, previousValue, previousValueLabel

  const updateUri = uri?.split(':')[0] === 'isbn' ? `inv:${entity._id}` : uri

  function showEditMode () {
    if (inputValue === Symbol.for('removed')) inputValue = null
    editMode = true
    flash = null
  }

  function closeEditMode () {
    editMode = false
    flash = null
    // Updates the parent array, mostly to remove a null value
    dispatch('set', inputValue)
  }

  const editorKey = `${uri || type}:${property}:${index}`
  const setCurrentEditorKey = () => $currentEditorKey = editorKey
  $: if (editMode) setCurrentEditorKey()
  $: if (editorKey !== $currentEditorKey) closeEditMode()

  async function save (newValue) {
    try {
      // Allow null to be passed when trying to remove a value
      // but ignore the argument when dispatch('save') is called without
      if (newValue === undefined || isComponentEvent(newValue)) {
        // TODO: show spinner while waiting
        newValue = await getInputValue()
      }
      inputValue = newValue
      editMode = false
      dispatch('set', inputValue)
      if (savedValue === inputValue) return
      if (!creationMode) {
        await preq.put(app.API.entities.claims.update, {
          uri: updateUri,
          property,
          'old-value': savedValue,
          'new-value': typeof newValue === 'symbol' ? null : newValue,
        })
      }
      previousValue = savedValue
      previousValueLabel = valueLabel
      savedValue = inputValue
    } catch (err) {
      // Revert change, unless that would mean removing this component
      // thus hiding the error
      if (savedValue === null) {
        editMode = true
      } else {
        inputValue = savedValue
        dispatch('set', inputValue)
      }
      flash = err
    }
  }

  const remove = () => {
    if (inputValue === null) {
      save(null)
    } else {
      save(Symbol.for('removed'))
    }
  }

  function onInputKeyup (componentEvent) {
    const domEvent = componentEvent.detail
    const key = getActionKey(domEvent)
    if (key === 'esc') closeEditMode()
    else if (domEvent.ctrlKey && key === 'enter') save()
  }

  function showError (componentEvent) {
    flash = componentEvent.detail
    editMode = false
  }

  let undoTitle
  $: {
    if (inputValue === Symbol.for('removed') && isNonEmptyClaimValue(previousValue)) {
      undoTitle = `${i18n('Recover previous value:')} ${previousValueLabel}`
      if (previousValue !== previousValueLabel) undoTitle += ` (${previousValue})`
    } else if (inputValue === null) {
      // Reset label
      valueLabel = ''
      editMode = true
    }
  }

  function undo () {
    save(previousValue)
  }
</script>

<div class="wrapper">
  <div class="value">
    {#if inputValue === Symbol.for('removed')}
      <button
        class="undo"
        title={undoTitle}
        on:click={undo}
        >
        {@html icon('undo')}
        {I18n('undo')}
      </button>
      <DisplayModeButtons on:edit={showEditMode} />
    {:else if editMode}
      <InputComponent
        {property}
        currentValue={inputValue}
        {valueLabel}
        {editorType}
        {entity}
        bind:getInputValue
        on:keyup={onInputKeyup}
        on:save={e => save(e.detail)}
        on:close={closeEditMode}
        on:error={showError}
      />
      <EditModeButtons
        {showSave}
        showDelete={isNonEmptyClaimValue(savedValue)}
        on:save={save}
        on:cancel={closeEditMode}
        on:delete={remove}
      />
    {:else if isNonEmptyClaimValue(savedValue)}
      <DisplayComponent
        {entity}
        {property}
        value={savedValue}
        bind:valueLabel
        on:edit={showEditMode}
        on:error={showError}
      />
      {#if !fixed}
        <DisplayModeButtons on:edit={showEditMode} />
      {/if}
    {:else}
      <!-- Known case: savedValue is not set yet, after a claim was created -->
      <Spinner />
    {/if}
  </div>

  <Flash bind:state={flash}/>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .value{
    @include display-flex(row, center, center);
    &:not(:last-child){
      margin-bottom: 1em;
    }
    /*Small screens*/
    @media screen and (max-width: $smaller-screen) {
      flex-direction: column;
      padding: 0.5em 0.2em;
      margin: 0.5em 0;
      :global(.edit-mode-buttons){
        margin-top: 1em;
      }
    }
  }
  .undo{
    flex: 1;
    padding: 0.6em 0;
    @include shy(0.9);
    @include bg-hover(#ddd);
  }
</style>
