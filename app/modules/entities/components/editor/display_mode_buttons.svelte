<script>
  import { icon } from '#lib/utils'
  import { I18n } from '#user/lib/i18n'
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
  .display-mode-button{
    height: 2.5rem;
  }
  button{
    height: 100%;
    max-height: 2.5em;
    font-weight: normal;
  }
</style>
