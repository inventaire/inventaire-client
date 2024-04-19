<script lang="ts">
  import Spinner from '#components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'

  export let total: number
  export let count: number
  export let message: string = null
  export let spinner = true
</script>
<div class="loading">
  <div class="count">
    {count}/{total}
  </div>
  {#if spinner}
    <Spinner />
  {/if}
  {#if message}
    {I18n(message)}...
  {/if}
</div>
<style lang="scss">
  @import "#modules/general/scss/utils";
  .count{
    min-width: 3em;
    text-align: end;
  }
</style>
