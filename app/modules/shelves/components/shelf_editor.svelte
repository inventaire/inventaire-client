<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { onMount } from 'svelte'
  import VisibilitySelector from '#general/components/visibility_selector.svelte'
  import { getSomeColorHexCodeSuggestion } from '#lib/images'
  import Flash from '#lib/components/flash.svelte'
  import { createShelf } from '#shelves/lib/shelves'
  import Spinner from '#components/spinner.svelte'

  onMount(() => {
    app.execute('modal:open')
  })

  let isNewShelf = true
  let name = '', description = '', visibility = [], color = getSomeColorHexCodeSuggestion()
  let flash, waitForCreation

  async function create () {
    try {
      waitForCreation = createShelf({ name, description, visibility, color })
      const newShelf = await waitForCreation
      app.user.trigger('shelves:change', 'createShelf')
      app.execute('show:shelf', newShelf)
      app.execute('modal:close')
    } catch (err) {
      flash = err
    }
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
    <textarea type="text" bind:value={description}></textarea>
  </label>

  <VisibilitySelector bind:visibility />

  <label>
    {i18n('color')}
    <input type="color" bind:value={color}>
  </label>

  <Flash state={flash} />

  <div class="buttons">
    {#if !isNewShelf}
      <button class="delete button">
        {@html icon('trash')}
        {I18n('delete')}
      </button>
    {/if}
    <button
      class="validate button success-button"
      title={name === '' ? i18n('A shelf name is required') : I18n('validate')}
      disabled={name === ''}
      on:click={create}
    >
      {#await waitForCreation}
        <Spinner />
      {:then}
        {@html icon('check')}
      {/await}
      {#if isNewShelf}
        {I18n('create')}
      {:else}
        {I18n('validate')}
      {/if}
    </button>
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
  /*Smaller screens*/
  @media screen and (max-width: $very-small-screen) {
    .shelf-editor{
      @include display-flex(column, center, center);
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
