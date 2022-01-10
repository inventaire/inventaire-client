<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  import { icon } from 'lib/utils'
  import { createEventDispatcher } from 'svelte'
  export let disableDelete
  const dispatch = createEventDispatcher()
</script>

<div class="edit-mode-buttons">
  <button class="tiny-button save" title="{I18n('save')} (Ctrl+Enter)">
    <span class="hide-on-loading">{@html icon('check')}</span>
    <span class="loading"></span>
    <span>{i18n('save')}</span>
  </button>
  <button
    class="tiny-button cancel"
    title="{I18n('cancel')} (Esc)"
    on:click={() => dispatch('cancel')}
  >
    {@html icon('times')}
  </button>
  {#if !disableDelete}
    <button class="tiny-button dangerous delete" title="{I18n('delete')}">
      {@html icon('trash')}
    </button>
  {/if}
</div>

<style>
  button{
    height: 100%;
    font-weight: normal;
  }
</style>
