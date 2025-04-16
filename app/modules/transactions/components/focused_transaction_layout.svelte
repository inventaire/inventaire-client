<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import CancelTransaction from '#transactions/components/cancel_transaction.svelte'
  import NewMessage from '#transactions/components/new_message.svelte'
  import TransactionHeader from '#transactions/components/transaction_header.svelte'
  import TransactionNextAction from '#transactions/components/transaction_next_action.svelte'
  import TransactionTimeline from '#transactions/components/transaction_timeline.svelte'
  import { attachLinkedDocs, type SerializedTransaction } from '#transactions/lib/transactions'

  export let transaction: SerializedTransaction

  let flash
  const waiting = attachLinkedDocs(transaction)
    .catch(err => flash = err)
</script>

<div class="focused-transaction-layout">
  <Flash state={flash} />
  {#await waiting}
    <Spinner center={true} />
  {:then}
    <section>
      <TransactionHeader {transaction} />
      <TransactionTimeline {transaction} />
    </section>
    <TransactionNextAction bind:transaction />
    <section class="new-message-section">
      <NewMessage bind:transaction />
    </section>
    <CancelTransaction bind:transaction />
  {/await}
</div>

<style lang="scss">
  @import '#general/scss/utils';

  .focused-transaction-layout{
    max-width: 40em;
    margin: 1em auto;
    :global(section){
      @include radius;
      @include shy-border;
      background-color: white;
    }
  }
  .new-message-section{
    margin-block-start: 1em;
  }
  /* Large screens */
  @media screen and (width >= $small-screen){
    .focused-transaction-layout{
      padding: 1em;
    }
  }
</style>
