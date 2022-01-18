<script>
  import Spinner from '#components/spinner.svelte'
  export let total, count, spinner = true

  $: if (count === total) count = 0
</script>
{#if count > 0}
  <p class="loading">
    {count}/{total}
    {#if spinner}
      <Spinner/>
    {/if}
  </p>
{/if}
