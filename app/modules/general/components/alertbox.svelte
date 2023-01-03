<script>
  import { createEventDispatcher } from 'svelte'
  import { I18n } from '#user/lib/i18n'
  const dispatch = createEventDispatcher()
  export let error
</script>

<div class="alert alert-box" role="alert">
  <span class="alert-message">{error.message}</span>
  <button
    on:click={() => dispatch('closed')}
    class="alert-close"
    title={I18n('close')}
    aria-label="${I18n('close')}">&#215;</button>
</div>
