<script>
  import DisplayModeButtons from './display_mode_buttons.svelte'
  import EditModeButtons from './edit_mode_buttons.svelte'
  import { autofocus } from 'lib/components/actions/autofocus'
  import { i18n } from 'modules/user/lib/i18n'
  import getActionKey from 'lib/get_action_key'
  import Flash from 'lib/components/flash.svelte'
  import preq from 'lib/preq'
  import { createEventDispatcher } from 'svelte'

  export let uri, property, value

  let editMode = (value == null)
  let oldValue = value
  let currentValue = value
  let input, flash
  const dispatch = createEventDispatcher()

  function showEditMode () { editMode = true }
  function closeEditMode () {
    editMode = false
    flash = null
    if (value === null) dispatch('remove')
  }
  async function save () {
    const { value } = input
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
    } catch (err) {
      editMode = true
      flash = err
    }
  }
  function onInputKeyup (e) {
    const key = getActionKey(e)
    if (key === 'esc') closeEditMode()
    else if (e.ctrlKey && key === 'enter') save()
  }
</script>

<div class="wrapper">
  <div class="value">
    {#if editMode}
      <input type="text"
        value={currentValue || ''}
        on:keyup={onInputKeyup}
        bind:this={input}
        use:autofocus
      >
      <EditModeButtons disableDelete={true} on:cancel={closeEditMode} on:save={save}/>
    {:else}
      <button class="value-display" on:click={showEditMode} title="{i18n('edit')}">
        {currentValue || ''}
      </button>
      <DisplayModeButtons on:edit={showEditMode} />
    {/if}
  </div>

  <Flash bind:state={flash}/>
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .value{
    height: 2.5em;
    @include display-flex(row, stretch);
    input, button{
      flex: 1;
      height: 100%;
      font-weight: normal;
      margin: 0 0.5em;
    }
    button{
      cursor: pointer;
      text-align: left;
      @include bg-hover(white, 5%);
      user-select: text;
    }
  }
</style>
