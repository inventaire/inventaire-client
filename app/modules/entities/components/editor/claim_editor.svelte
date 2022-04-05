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
  import { isNonEmptyClaimValue } from '#entities/components/editor/lib/editors_helpers'

  export let entity, property, value, index, editModeIndex

  const dispatch = createEventDispatcher()
  const { uri } = entity
  const creationMode = uri == null
  const { editorType } = properties[property]
  const { InputComponent, DisplayComponent, showSave } = editors[editorType]
  const fixed = editorType.split('-')[0] === 'fixed'

  let editMode = (value == null)
  if (editMode) editModeIndex = index

  let oldValue = value
  let getInputValue, flash, valueLabel, showDelete, previousValue, previousValueLabel

  const updateUri = uri?.split(':')[0] === 'isbn' ? `inv:${entity._id}` : uri

  function showEditMode () {
    if (value === Symbol.for('removed')) value = null
    editMode = true
    editModeIndex = index
  }

  function closeEditMode () {
    editMode = false
    flash = null
    // Updates the parent array, mostly to remove a null value
    dispatch('set', value)
  }

  function closeEditModeIfAnotherClaimIsEdited () {
    if (editMode && editModeIndex !== index) {
      editMode = false
    }
  }

  $: editModeIndex != null && closeEditModeIfAnotherClaimIsEdited()

  async function save (newValue) {
    try {
      // Allow null to be passed when trying to remove a value
      // but ignore the argument when dispatch('save') is called without
      if (newValue === undefined || isComponentEvent(newValue)) {
        // TODO: show spinner while waiting
        newValue = await getInputValue()
      }
      value = newValue
      editMode = false
      dispatch('set', value)
      if (oldValue === value) return
      if (!creationMode) {
        await preq.put(app.API.entities.claims.update, {
          uri: updateUri,
          property,
          'old-value': oldValue,
          'new-value': typeof newValue === 'symbol' ? null : newValue,
        })
      }
      previousValue = oldValue
      previousValueLabel = valueLabel
      oldValue = value
    } catch (err) {
      showEditMode()
      flash = err
    }
  }

  const remove = () => {
    if (value === null) {
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
  function showError (componentEvent) { flash = componentEvent.detail }

  let undoTitle
  $: {
    if (value === Symbol.for('removed') && isNonEmptyClaimValue(previousValue)) {
      undoTitle = `${i18n('Recover previous value:')} ${previousValueLabel}`
      if (previousValue !== previousValueLabel) undoTitle += ` (${previousValue})`
    }
  }

  function undo () {
    save(previousValue)
  }
</script>

<div class="wrapper">
  <div class="value">
    {#if value === Symbol.for('removed')}
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
        currentValue={value}
        {valueLabel}
        {editorType}
        {entity}
        bind:getInputValue
        bind:showDelete
        on:keyup={onInputKeyup}
        on:save={e => save(e.detail)}
        on:close={closeEditMode}
        on:error={showError}
      />
      <EditModeButtons
        {showSave}
        {showDelete}
        on:save={save}
        on:cancel={closeEditMode}
        on:delete={remove}
      />
    {:else}
      <DisplayComponent
        {entity}
        {property}
        {value}
        bind:valueLabel
        on:edit={showEditMode}
        on:error={showError}
      />
      {#if !fixed}
        <DisplayModeButtons on:edit={showEditMode} />
      {/if}
    {/if}
  </div>

  <Flash bind:state={flash}/>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .value{
    @include display-flex(row, center);
    &:not(:last-child){
      margin-bottom: 1em;
    }
    /*Small screens*/
    @media screen and (max-width: $very-small-screen) {
      flex-direction: column;
      padding: 0.5em 0.2em;
      margin: 0.5em 0;
    }
  }
  .undo{
    flex: 1;
    padding: 0.6em 0;
    @include shy(0.9);
    @include bg-hover(#ddd);
  }
</style>
