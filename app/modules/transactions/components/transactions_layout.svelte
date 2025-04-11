<script lang="ts">
  import { tick } from 'svelte'
  import { slide } from 'svelte/transition'
  import { partition, without } from 'underscore'
  import app from '#app/app'
  import { icon } from '#app/lib/icons'
  import { wait } from '#app/lib/promises'
  import { onChange } from '#app/lib/svelte/svelte'
  import { elementIsInViewport } from '#app/lib/utils'
  import FocusedTransactionLayout from '#transactions/components/focused_transaction_layout.svelte'
  import TransactionsList from '#transactions/components/transactions_list.svelte'
  import TransactionsWelcome from '#transactions/components/transactions_welcome.svelte'
  import { getUnreadTransactionsListCount, isArchived, isOngoing, markAsRead, type SerializedTransaction } from '#transactions/lib/transactions'
  import { I18n } from '#user/lib/i18n'

  export let transactions: SerializedTransaction[]
  export let selectedTransaction: SerializedTransaction = null

  let showOngoingTransactions = true
  let showArchivedTransactions = false

  let ongoing, archived
  function displaySomeTransaction () {
    selectedTransaction ??= ongoing[0]
    showArchivedTransactions = showArchivedTransactions || ongoing.length === 0 || (selectedTransaction && isArchived(selectedTransaction)) || getUnreadTransactionsListCount(archived) > 0
  }
  $: {
    ;[ ongoing, archived ] = partition(transactions, isOngoing)
    displaySomeTransaction()
  }

  async function showSelectedTransaction () {
    if (selectedTransaction) {
      if (!selectedTransaction.mainUserRead) {
        await markAsRead(selectedTransaction)
        selectedTransaction.mainUserRead = true
        transactions = transactions
      }
      if (isArchived(selectedTransaction) && ongoing.includes(selectedTransaction)) {
        ongoing = without(ongoing, selectedTransaction)
        archived = [ selectedTransaction, ...ongoing ]
      }
      app.navigate(selectedTransaction.pathname)
    } else {
      app.navigate('/transactions')
    }
  }

  async function scrollToSection (el: HTMLElement) {
    await tick()
    await wait(100)
    el?.scrollIntoView({ block: 'start', inline: 'nearest', behavior: 'smooth' })
  }

  let ongoingTransactionsEl: HTMLElement
  async function toggleOngoingTransaction () {
    const wasPreviouslyShown = showOngoingTransactions
    if (elementIsInViewport(ongoingTransactionsEl)) {
      showOngoingTransactions = !showOngoingTransactions
    } else {
      // As the .list-header is sticky, the header might be visible while the whole section is out of viewport.
      // Clicking on the header in that case scrolls back to the ongoing transactions list rather than closing it:
      // it's already out of view, so the desired behavior when clicking is unlikely to be to hide it
      showOngoingTransactions = true
    }
    if (showOngoingTransactions) {
      // This extra tick await seems required to let the time to properly render the list before trying to scroll
      if (!wasPreviouslyShown) await tick()
      scrollToSection(ongoingTransactionsEl)
    }
  }

  let archivedTransactionsEl: HTMLElement
  async function toggleArchivedTransaction () {
    showArchivedTransactions = !showArchivedTransactions
    if (showArchivedTransactions) scrollToSection(archivedTransactionsEl)
  }

  $: onChange(selectedTransaction, showSelectedTransaction)
  $: unreadOngoingTransactionsCount = getUnreadTransactionsListCount(ongoing)
  $: unreadArchivedTransactionsCount = getUnreadTransactionsListCount(archived)
</script>

<div id="list">
  <button
    class="list-header first"
    aria-controls="ongoing-transactions"
    class:wrapped={!showOngoingTransactions}
    on:click={toggleOngoingTransaction}
  >
    {@html icon('caret-down')}
    {@html icon('exchange')}
    {I18n('ongoing')}
    {#if unreadOngoingTransactionsCount > 0}
      <span class="counter">{unreadOngoingTransactionsCount}</span>
    {/if}
  </button>
  {#if ongoing && showOngoingTransactions}
    <section id="ongoing-transactions" transition:slide bind:this={ongoingTransactionsEl}>
      <TransactionsList transactions={ongoing} bind:selectedTransaction />
    </section>
  {/if}

  <button
    class="list-header second"
    aria-controls="archived-transactions"
    class:wrapped={!showArchivedTransactions}
    on:click={toggleArchivedTransaction}
  >
    {@html icon('caret-down')}
    {@html icon('exchange')}
    {I18n('archived')}
    {#if unreadArchivedTransactionsCount > 0}
      <span class="counter">{unreadArchivedTransactionsCount}</span>
    {/if}
  </button>
  {#if archived && showArchivedTransactions}
    <section id="archived-transactions" transition:slide bind:this={archivedTransactionsEl}>
      <TransactionsList transactions={archived} bind:selectedTransaction />
    </section>
  {/if}
</div>

<div id="fullview">
  {#if selectedTransaction}
    {#key selectedTransaction._id}
      <FocusedTransactionLayout bind:transaction={selectedTransaction} />
    {/key}
  {:else}
    <TransactionsWelcome />
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  $transaction-list-width: 20em;
  $transaction-list-header-height: 2.2rem;

  #list{
    background-color: #fefefe;
    overflow-y: auto;
    position: relative;
    // Required to avoid having transactionPreviewEl.scrollIntoView scroll too far
    // and get the transactionPreviewEl displayed below the .list-header
    // Adding *2 for the worst case scenario where the focused transaction is archived,
    // and thus the 2 .list-header are stacked
    // And 0.5 more, to give a hint that there is more content above
    scroll-padding-top: $transaction-list-header-height * 2.5;
  }
  .list-header{
    position: sticky;
    // z-index is required with the position=sticky to not have the .unread-flag pass over this button
    // See https://stackoverflow.com/a/53107499
    z-index: 1;
    width: 100%;
    height: $transaction-list-header-height;
    &.first{
      inset-block-start: 0;
    }
    &.second{
      inset-block-start: $transaction-list-header-height;
    }
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
  @media screen and (width < $small-screen){
    #list{
      margin-block-end: 1em;
      max-height: 50vh;
      border-block-end: 1px solid #ccc;
    }
  }

  /* Large screens */
  @media screen and (width >= $small-screen){
    #list{
      @include position(fixed, $topbar-height, null, 0);
      width: $transaction-list-width;
    }
    #fullview{
      margin-inline-start: $transaction-list-width;
    }
  }
</style>
