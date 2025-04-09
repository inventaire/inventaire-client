<script lang="ts">
  import TransactionPreview from '#transactions/components/transaction_preview.svelte'
  import { I18n } from '#user/lib/i18n'
  import type { SerializedTransaction } from '../lib/transactions'

  export let transactions: SerializedTransaction[]
  export let selectedTransaction = null
</script>

<div class="transaction-list">
  <div class="transactions">
    {#each transactions as transaction (transaction._id)}
      <TransactionPreview
        {transaction}
        bind:selectedTransaction
      />
    {:else}
      <div class="no-transaction">
        <em>{I18n('no_transaction')}</em>
      </div>
    {/each}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';

  .transaction-list{
    @include shy-border;
  }
  .no-transaction{
    background-color: $light-grey;
    text-align: center;
    opacity: 0.5;
  }
</style>
