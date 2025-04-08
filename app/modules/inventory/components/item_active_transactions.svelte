<script lang="ts">
  import Spinner from '#components/spinner.svelte'
  import TransactionPreview from '#transactions/components/transaction_preview.svelte'
  import { getActiveTransactionsByItemId } from '#transactions/lib/transactions'
  import { I18n } from '#user/lib/i18n'

  export let item, flash

  let transactions
  const waitingForTransactions = getActiveTransactionsByItemId(item._id)
    .then(res => transactions = res)
    .catch(err => flash = err)
</script>

{#await waitingForTransactions}
  <Spinner />
{:then}
  {#if transactions.length > 0}
    <div class="item-active-transactions">
      <span class="section-label">{I18n('transactions')}</span>
      <ul>
        {#each transactions as transaction}
          <TransactionPreview {transaction} onItem={true} />
        {/each}
      </ul>
    </div>
  {/if}
{/await}

<style lang="scss">
  @use "#general/scss/utils";
  .item-active-transactions{
    margin-block-start: 1em;
    background: $off-white;
    @include radius;
  }
  .section-label{
    padding: 0.5em;
  }
</style>
