<script>
  import { icon } from 'lib/utils'
  import { I18n } from 'modules/user/lib/i18n'
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()
</script>

<div class="display-mode-button">
  <button
    class="tiny-button light-blue shy-label"
    on:click={() => dispatch('edit')}
  >
    {@html icon('pencil')}
    <span>{I18n('edit')}</span>
  </button>
</div>

<style>
  button{
    height: 100%;
    font-weight: normal;
  }
</style>
