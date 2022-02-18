<script>
  import properties from '#entities/lib/properties'
  import { editors } from '../lib/editors.js'
  import { createEventDispatcher } from 'svelte'
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import getActionKey from '#lib/get_action_key'
  import Flash from '#lib/components/flash.svelte'
  import preq from '#lib/preq'
  import { isComponentEvent } from '#lib/boolean_tests'
  import { i18n } from '#user/lib/i18n'

  export let entity, property, value

  const dispatch = createEventDispatcher()
  const { uri } = entity
  const { editorType } = properties[property]
  const { InputComponent, DisplayComponent, showSave } = editors[editorType]
  const fixed = editorType.split('-')[0] === 'fixed'

  let editMode = (value == null)
  let oldValue = value
  let currentValue = value
  let getInputValue, flash, valueLabel

  const updateUri = uri.split(':')[0] === 'isbn' ? `inv:${entity._id}` : uri

  function showEditMode () { editMode = true }
  function closeEditMode () {
    editMode = false
    flash = null
    // Updates the parent array, mostly to remove a null value
    dispatch('set', currentValue)
  }

  async function save (value) {
    try {
      // Allow null to be passed when trying to remove a value
      // but ignore the argument when dispatch('save') is called without
      if (value === undefined || isComponentEvent(value)) {
        value = getInputValue()
      }
      editMode = false
      currentValue = value
      if (oldValue === currentValue) return
      dispatch('set', currentValue)
      await preq.put(app.API.entities.claims.update, {
        uri: updateUri,
        property,
        'old-value': oldValue,
        'new-value': value,
      })
      oldValue = currentValue
    } catch (err) {
      editMode = true
      flash = err
    }
  }

  const remove = () => {
    app.execute('ask:confirmation', {
      confirmationText: i18n('Are you sure you want to delete this statement?'),
      action: () => save(null)
    })
  }

  function onInputKeyup (componentEvent) {
    const domEvent = componentEvent.detail
    const key = getActionKey(domEvent)
    if (key === 'esc') closeEditMode()
    else if (domEvent.ctrlKey && key === 'enter') save()
  }
  function showError (componentEvent) { flash = componentEvent.detail }
</script>

<div class="wrapper">
  <div class="value">
    {#if editMode}
      <InputComponent
        {property}
        {currentValue}
        {valueLabel}
        {entity}
        bind:getInputValue
        on:keyup={onInputKeyup}
        on:save={e => save(e.detail)}
        on:close={closeEditMode}
        on:error={showError}
      />
      <EditModeButtons
        {showSave}
        on:save={save}
        on:cancel={closeEditMode}
        on:delete={remove}
      />
    {:else}
      <DisplayComponent
        {entity} {uri} {property} {value}
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
  }
</style>
