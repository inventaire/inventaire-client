<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/icons'
  import TransactionsList from '#transactions/components/transactions_list.svelte'
  import { slide } from 'svelte/transition'
  import { partition } from 'underscore'
  import { isOngoing } from '#transactions/lib/transactions'
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
    showArchivedTransactions = showArchivedTransactions || ongoing.length === 0
  }
  $: {
    ;[ ongoing, archived ] = partition(transactions, isOngoing)
    displayFirstTransaction()
  }
  function navigate () {
    if (selectedTransaction) {
      app.navigate(selectedTransaction.pathname)
    } else {
      app.navigate('/transactions')
    }
  }
  $: onChange(selectedTransaction, navigate)
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
  }
  button{
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
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    #list{
      margin-block-end: 1em;
    }
  }

  /* Large screens */
  @media screen and (min-width: $small-screen){
    #list{
      @include position(fixed, $topbar-height, null, 0);
      width: $transaction-list-width;
      overflow-y: auto;
    }
    #fullview{
      margin-inline-start: $transaction-list-width;
    }
  }
</style>
