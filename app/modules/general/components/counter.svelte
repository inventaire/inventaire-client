<script>
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#components/spinner.svelte'
  export let total, count, message, spinner = true

  $: if (count === total) count = 0
</script>
{#if count > 0}
  <p class="loading">
    {count}/{total}
    {#if spinner}
      <Spinner/>
    {/if}
    {#if message}
      {I18n(message)}...
    {/if}
  </p>
{/if}
