<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import autosize from 'autosize'
  import { onMount } from 'svelte'
  import VisibilitySelector from '#inventory/components/visibility_selector.svelte'
  import { getSomeColorHexCodeSuggestion } from '#lib/images'
  import Flash from '#lib/components/flash.svelte'
  import { createShelf, updateShelf, deleteShelf } from '#shelves/lib/shelves'
  import Spinner from '#components/spinner.svelte'
  import { wait } from '#lib/promises'

  export let shelf = {}, model = null

  onMount(() => app.execute('modal:open'))

  let isNewShelf = !shelf._id

  let {
    name = '',
    description = '',
    visibility = [],
    color = getSomeColorHexCodeSuggestion()
  } = shelf

  let flash, waiting
  async function validate () {
    try {
      if (isNewShelf) {
        waiting = createShelf({ name, description, visibility, color })
        const newShelf = await waiting
        app.user.trigger('shelves:change', 'createShelf')
        app.execute('show:shelf', newShelf)
      } else {
        waiting = updateShelf({ shelf: shelf._id, name, description, visibility, color })
        await waiting
        model.set({ name, description, visibility, color })
      }
      flash = { type: 'success', message: I18n('saved') }
      await wait(800)
      app.execute('modal:close')
    } catch (err) {
      flash = err
    }
  }
  async function askShelfDeletionConfirmation () {
    app.execute('ask:confirmation', {
      confirmationText: i18n('delete_shelf_confirmation', { name }),
      warningText: i18n('cant_undo_warning'),
      action: _deleteShelf
    })
  }

  async function _deleteShelf () {
    // TODO: catch and display error
    await deleteShelf({ ids: shelf._id })
    app.user.trigger('shelves:change', 'removeShelf')
    app.execute('show:inventory:main:user')
    app.execute('modal:close')
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
    <input type="text" bind:value={name} required>
  </label>

  <label>
    {i18n('description')}
    <textarea type="text" bind:value={description} use:autosize></textarea>
  </label>

  <VisibilitySelector bind:visibility showTip={true} />

  <label>
    {i18n('color')}
    <input type="color" bind:value={color}>
  </label>

  <Flash state={flash} />

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
  @import '#general/scss/utils';
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
    margin-bottom: 0.2em;
    cursor: pointer;
  }
  h3{
    text-align: center;
  }
  .buttons{
    margin-top: 1em;
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
  /*Small screens*/
  @media screen and (max-width: $very-small-screen) {
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
  /*Large screens*/
  @media screen and (min-width: $very-small-screen) {
    .buttons{
      @include display-flex(row, center, space-around);
    }
    .delete{
      margin-right: 0.5em;
    }
    .validate{
      margin-left: 0.5em;
    }
  }
</style>
