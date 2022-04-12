<script>
  import { I18n } from '#user/lib/i18n'
  import Spinner from '#components/spinner.svelte'
  export let total, count, message, spinner = true
</script>
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
<style lang="scss">
  @import '#modules/general/scss/utils';
  .count{
    min-width: 3em;
    text-align: right;
  }
</style>
