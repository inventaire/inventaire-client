<script lang="ts">
  import autosize from 'autosize'
  import { createEventDispatcher } from 'svelte'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { getSomeColorHexCodeSuggestion } from '#app/lib/images/images'
  import { wait } from '#app/lib/promises'
  import { commands } from '#app/radio'
  import Spinner from '#components/spinner.svelte'
  import { askConfirmation } from '#general/lib/confirmation_modal'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import { createShelf, updateShelf, deleteShelf } from '#shelves/lib/shelves'
  import { i18n, I18n } from '#user/lib/i18n'
  import { updateMainUserShelvesCount } from '#user/lib/main_user'
  import { showShelf } from '../shelves'

  export let shelf

  const dispatch = createEventDispatcher()

  const isNewShelf = !shelf._id

  let {
    name = '',
    description = '',
    visibility = [],
    color = getSomeColorHexCodeSuggestion(),
  } = shelf

  let flash, waiting
  async function validate () {
    try {
      if (isNewShelf) {
        waiting = createShelf({ name, description, visibility, color })
        const newShelf = await waiting
        updateMainUserShelvesCount(1)
        showShelf(newShelf)
      } else {
        waiting = updateShelf({ shelf: shelf._id, name, description, visibility, color })
        await waiting
        shelf = Object.assign(shelf, { name, description, visibility, color })
      }
      flash = { type: 'success', message: I18n('saved') }
      await wait(800)
      dispatch('shelfEditorDone')
    } catch (err) {
      flash = err
    }
  }
  async function askShelfDeletionConfirmation () {
    askConfirmation({
      confirmationText: I18n('delete_shelf_confirmation', { name }),
      warningText: I18n('cant_undo_warning'),
      action: _deleteShelf,
    })
  }

  async function _deleteShelf () {
    // TODO: catch and display error
    await deleteShelf({ ids: shelf._id })
    updateMainUserShelvesCount(-1)
    commands.execute('show:inventory:main:user')
  }
</script>

<div class="shelf-editor">
  <h3>
    {#if isNewShelf}
      {I18n('create a new shelf')}
    {:else}
      {I18n('edit shelf')}
    {/if}
  </h3>

  <label>
    {i18n('name')}
    <input type="text" bind:value={name} required />
  </label>

  <label>
    {i18n('description')}
    <textarea type="text" bind:value={description} use:autosize />
  </label>

  <VisibilitySelector bind:visibility showTip={true} />

  <label>
    {i18n('color')}
    <input type="color" bind:value={color} />
  </label>

  <Flash bind:state={flash} />

  <div class="buttons">
    {#await waiting}
      <Spinner />
    {:then}
      {#if !flash}
        {#if !isNewShelf}
          <button class="delete button" on:click={askShelfDeletionConfirmation}>
            {@html icon('trash')}
            {I18n('delete')}
          </button>
        {/if}
        <button
          class="validate button success-button"
          title={name === '' ? i18n('A shelf name is required') : I18n('validate')}
          disabled={name === ''}
          on:click={validate}
        >
          {@html icon('check')}
          {#if isNewShelf}
            {I18n('create')}
          {:else}
            {I18n('validate')}
          {/if}
        </button>
      {/if}
    {/await}
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .shelf-editor{
    padding: 0 0.5em;
    label, :global(fieldset){
      margin: 1em 0;
    }
  }
  input:invalid:not(:focus){
    border: 1px solid red;
  }
  label{
    font-size: 1rem;
    margin-block-end: 0.2em;
    cursor: pointer;
  }
  h3{
    text-align: center;
  }
  .buttons{
    margin-block-start: 1em;
    align-self: stretch;
  }
  .delete, .validate{
    text-align: center;
    font-weight: bold;
    padding: 0.7em;
    flex: 1;
  }
  .delete{
    @include dangerous-action;
  }
  /* Very small screens */
  @media screen and (width < $very-small-screen){
    .shelf-editor{
      label, :global(fieldset){
        padding: 0 0.5em;
      }
    }
    .buttons{
      align-self: stretch;
      flex: 1;
      padding: 1em;
      @include display-flex(column, stretch, center);
      button{
        min-width: 12em;
        max-width: 20em;
        margin: 0.5em auto;
      }
    }
  }
  /* Large screens */
  @media screen and (width >= $very-small-screen){
    .buttons{
      @include display-flex(row, center, space-around);
    }
    .delete{
      margin-inline-end: 0.5em;
    }
    .validate{
      margin-inline-start: 0.5em;
    }
  }
</style>
