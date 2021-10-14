<script>
  import { createEventDispatcher } from 'svelte'
  import { I18n } from 'modules/user/lib/i18n'
  const dispatch = createEventDispatcher()
  export let error
</script>

<div class='alert alert-box'>
  <span class='alert-message'>{error.message}</span>
  <button on:click="{() => dispatch('closed')}" class='alert-close' title="{ I18n('close') }">&#215;</button>
</div>
