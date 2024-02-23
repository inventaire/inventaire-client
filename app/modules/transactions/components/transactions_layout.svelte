<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/icons'
  import TransactionsList from '#transactions/components/transactions_list.svelte'
  import { slide } from 'svelte/transition'
  import { partition } from 'underscore'
  import { getUnreadTransactionsListCount, isArchived, isOngoing, markAsRead } from '#transactions/lib/transactions'
  import FocusedTransactionLayout from '#transactions/components/focused_transaction_layout.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import TransactionsWelcome from '#transactions/components/transactions_welcome.svelte'

  export let transactions
  export let selectedTransaction = null

  let showOngoingTransactions = true
  let showArchivedTransactions = false

  let ongoing, archived
  function displayFirstTransaction () {
    selectedTransaction = selectedTransaction || ongoing[0]
    showArchivedTransactions = showArchivedTransactions || ongoing.length === 0 || (selectedTransaction && isArchived(selectedTransaction))
  }
  $: {
    ;[ ongoing, archived ] = partition(transactions, isOngoing)
    displayFirstTransaction()
  }
  async function showSelectedTransaction () {
    if (selectedTransaction) {
      if (!selectedTransaction.mainUserRead) {
        await markAsRead(selectedTransaction)
        selectedTransaction.mainUserRead = true
        transactions = transactions
      }
      app.navigate(selectedTransaction.pathname)
    } else {
      app.navigate('/transactions')
    }
  }
  $: onChange(selectedTransaction, showSelectedTransaction)
  $: unreadOngoingTransactionsCount = getUnreadTransactionsListCount(ongoing)
  $: unreadArchivedTransactionsCount = getUnreadTransactionsListCount(archived)
</script>

<div id="list">
  <button
    aria-controls="ongoing-transactions"
    class:wrapped={!showOngoingTransactions}
    on:click={() => showOngoingTransactions = !showOngoingTransactions}
  >
    {@html icon('caret-down')}
    {@html icon('exchange')}
    {I18n('ongoing')}
    {#if unreadOngoingTransactionsCount > 0}
      <span class="counter">{unreadOngoingTransactionsCount}</span>
    {/if}
  </button>
  {#if ongoing && showOngoingTransactions}
    <section id="ongoing-transactions" transition:slide>
      <TransactionsList transactions={ongoing} bind:selectedTransaction />
    </section>
  {/if}

  <button
    aria-controls="archived-transactions"
    class:wrapped={!showArchivedTransactions}
    on:click={() => showArchivedTransactions = !showArchivedTransactions}
  >
    {@html icon('caret-down')}
    {@html icon('exchange')}
    {I18n('archived')}
    {#if unreadArchivedTransactionsCount > 0}
      <span class="counter">{unreadArchivedTransactionsCount}</span>
    {/if}
  </button>
  {#if archived && showArchivedTransactions}
    <section id="archived-transactions" transition:slide>
      <TransactionsList transactions={archived} bind:selectedTransaction />
    </section>
  {/if}
</div>

<div id="fullview">
  {#if selectedTransaction}
    {#key selectedTransaction._id}
      <FocusedTransactionLayout transaction={selectedTransaction} />
    {/key}
  {:else}
    <TransactionsWelcome />
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  $transaction-list-width: 20em;

  #list{
    background-color: #fefefe;
    overflow-y: auto;
    position: relative;
  }
  button{
    position: sticky;
    inset-block-start: 0;
    width: 100%;
    @include display-flex(row, center, flex-start);
    color: $grey;
    text-transform: uppercase;
    padding: 0.5em 0 0.5em 0.2em;
    @include shy-border;
    :global(.fa){
      margin: 0 0.2em;
      @include transition(transform, 0.2s);
    }
    &.wrapped{
      :global(.fa-caret-down){
        transform: rotate(-90deg);
      }
    }
    .counter{
      margin-inline-start: auto;
      margin-inline-end: 0.5em;
      @include counter-commons;
    }
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    #list{
      margin-block-end: 1em;
      max-height: 50vh;
      border-block-end: 1px solid #ccc;
    }
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    #list{
      @include position(fixed, $topbar-height, null, 0);
      width: $transaction-list-width;
    }
    #fullview{
      margin-inline-start: $transaction-list-width;
    }
  }
</style>
