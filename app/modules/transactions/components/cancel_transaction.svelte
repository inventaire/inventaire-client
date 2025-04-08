<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import { askConfirmation } from '#general/lib/confirmation_modal'
  import { updateTransactionState } from '#transactions/lib/transactions'
  import { transactionIsCancellable } from '#transactions/lib/transactions_actions'
  import { i18n } from '#user/lib/i18n'

  export let transaction

  let cancelling, flash
  async function askConfirmationToCancel () {
    askConfirmation({
      confirmationText: i18n('transaction_cancel_confirmation'),
      action: cancel,
    })
  }

  async function cancel () {
    try {
      cancelling = true
      transaction = await updateTransactionState({ transaction, state: 'cancelled' })
    } catch (err) {
      flash = err
    } finally {
      cancelling = false
    }
  }

  $: cancellable = transactionIsCancellable(transaction)
</script>

{#if cancellable}
  <div class="bottom-actions">
    <p>
      {i18n('transaction_cancel_info')}<br />
      {i18n('transaction_cancel_effects')}
    </p>
    <button
      class="action cancel"
      on:click={askConfirmationToCancel}
      disabled={cancelling}
    >
      {#if cancelling}<Spinner />{/if}
      {i18n('cancel')}
    </button>
    <Flash state={flash} />
  </div>
{/if}

<style lang="scss">
  @use '#general/scss/utils';

  .bottom-actions{
    text-align: center;
    p{
      color: grey;
      margin-block-end: 0.5em;
    }
  }
  .cancel{
    @include dangerous-action;
    @include tiny-button-padding;
    @include radius;
  }
</style>
