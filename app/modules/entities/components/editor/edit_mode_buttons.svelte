<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { icon } from '#app/lib/icons'
  import Spinner from '#components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'

  export let showSave = true
  export let showDelete = true
  export let saving = false
  export let deleteButtonDisableMessage: string = null

  const dispatch = createEventDispatcher()
</script>

<div class="edit-mode-buttons">
  <!-- Display save spinner -->
  {#if showSave !== false}
    <button
      class="tiny-button save"
      title="{I18n('save')} (Ctrl+Enter)"
      disabled={saving}
      on:click={() => dispatch('save')}
    >
      {I18n('save')}
      {#if saving}
        <Spinner />
      {/if}
    </button>
  {/if}
  <button
    class="tiny-button cancel"
    title="{I18n('cancel')} (Esc)"
    disabled={saving}
    on:click={() => dispatch('cancel')}
  >
    {@html icon('times')}
  </button>
  {#if showDelete !== false}
    <button
      class="tiny-button dangerous delete"
      title={deleteButtonDisableMessage != null ? deleteButtonDisableMessage : I18n('delete')}
      disabled={saving || deleteButtonDisableMessage != null}
      on:click={() => dispatch('delete')}
    >
      {@html icon('trash')}
    </button>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .edit-mode-buttons{
    flex: 0 0 auto;
    @include display-flex(row);
  }
  button{
    display: block;
    block-size: 100%;
    font-weight: normal;
  }
  .save{
    @include tiny-button-color($success-color);
  }
  .dangerous{
    background-color: $dark-grey;
  }
  /* Very small screens */
  @media screen and (width < $very-small-screen){
    button{
      padding: 0.5em;
      margin: 0.2em;
    }
  }
  /* Large screens */
  @media screen and (width >= $very-small-screen){
    .edit-mode-buttons{
      block-size: 2.5rem;
    }
    button{
      margin-inline-start: 0.2em;
    }
  }
</style>
