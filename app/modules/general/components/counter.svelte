<script>
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#components/spinner.svelte'
  export let total, count, message, spinner = true

  $: if (count === total) count = 0
</script>
{#if count > 0}
  <div class="loading">
    <div class="count">
      {count}/{total}
    </div>
    {#if spinner}
      <Spinner/>
    {/if}
    {#if message}
      {I18n(message)}...
    {/if}
  </div>
{/if}
<style lang="scss">
  @import '#modules/general/scss/utils';
  .count{
    min-width: 3em;
    text-align: right;
  }
</style>
