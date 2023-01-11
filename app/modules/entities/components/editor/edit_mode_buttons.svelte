<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { createEventDispatcher } from 'svelte'
  export let showSave, showDelete
  const dispatch = createEventDispatcher()
</script>

<div class="edit-mode-buttons">
  {#if showSave !== false}
    <button
      class="tiny-button save"
      title="{I18n('save')} (Ctrl+Enter)"
      on:click={() => dispatch('save')}
    >
      {I18n('save')}
    </button>
  {/if}
  <button
    class="tiny-button cancel"
    title="{I18n('cancel')} (Esc)"
    on:click={() => dispatch('cancel')}
  >
    {@html icon('times')}
  </button>
  {#if showDelete !== false}
    <button
      class="tiny-button dangerous delete"
      title={I18n('delete')}
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
    height: 100%;
    font-weight: normal;
  }
  .save{
    @include tiny-button-color($success-color);
  }
  .dangerous{
    background-color: $dark-grey;
  }
  /* Small screens */
  @media screen and (max-width: $below-very-small-screen){
    button{
      padding: 0.5em;
      margin: 0.2em;
    }
  }
  /* Large screens */
  @media screen and (min-width: $very-small-screen){
    .edit-mode-buttons{
      height: 2.5rem;
    }
    button{
      margin-left: 0.2em;
    }
  }
</style>
