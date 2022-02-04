<script>
  import { I18n } from 'modules/user/lib/i18n'
  import { icon } from 'lib/utils'
  import { createEventDispatcher } from 'svelte'
  export let disableDelete
  const dispatch = createEventDispatcher()
</script>

<div class="edit-mode-buttons">
  <button
    class="tiny-button save"
    title="{I18n('save')} (Ctrl+Enter)"
    on:click={() => dispatch('save')}
    >
    {I18n('save')}
  </button>
  <button
    class="tiny-button cancel"
    title="{I18n('cancel')} (Esc)"
    on:click={() => dispatch('cancel')}
    >
    {@html icon('times')}
  </button>
  {#if disableDelete !== true}
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
  @import 'app/modules/general/scss/utils';
  .edit-mode-buttons{
    height: 2.5rem;
  }
  button{
    height: 100%;
    font-weight: normal;
    margin-left: 0.2em;
  }
  .save{
    @include tiny-button-color($success-color);
  }
  .dangerous{
    background-color: $dark-grey;
  }
</style>
