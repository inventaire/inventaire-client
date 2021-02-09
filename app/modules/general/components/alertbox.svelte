<script>
  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()
  export let error
</script>

<div class='alert alert-box'>
  <span class='alert-message'>{error.message}</span>
  <button on:click={() => dispatch('closed')} class='alert-close'>&#215;</button>
</div>
