<script lang="ts">
  import { icon } from '#app/lib/icons'
  import { getLocalTimeString, timeFromNow } from '#app/lib/time'
  import { actionsIcons, getTransactionStateText } from '#transactions/lib/transactions'

  export let action, transaction

  const { timestamp, action: actionName } = action
  const context = getTransactionStateText({ transaction, action })
  const actionsIcon = actionsIcons[actionName]
</script>

<div class="action">
  {#if context}
    <span class="context">{@html icon(actionsIcon)} {@html context}</span>
    <span class="time" title={getLocalTimeString(timestamp)}>{timeFromNow(timestamp)}</span>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#transactions/scss/transactions_commons';
  .action{
    padding: 1em 0 1em 0.2em;
  }
  .context{
    // above the timeline vertical bar
    z-index: 2;
    background-color: white;
    :global(.fa){
      color: $dark-grey;
      padding: 0.3em 0.5em 0.4em;
      margin-inline-end: 0.5em;
    }
  }
  .time{
    opacity: 0.5;
    padding-inline-end: 0.5em;
  }
  /* Small screens */
  @media screen and (width <= 600px){
    .action{
      @include display-flex(column);
    }
    .time{
      margin-inline-start: auto;
    }
  }
  /* Large screens */
  @media screen and (width >= 600px){
    .action{
      @include display-flex(row, center, space-between);
    }
  }
</style>
