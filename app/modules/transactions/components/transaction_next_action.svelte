<script lang="ts">
  import Spinner from '#components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { getNextActionsData } from '#transactions/lib/next_actions'
  import { updateTransactionState } from '#transactions/lib/transactions'
  import { I18n, i18n } from '#user/lib/i18n'

  export let transaction

  $: nextActions = getNextActionsData(transaction)

  let flash, updating
  async function updateState (state) {
    try {
      updating = state
      transaction = await updateTransactionState({ transaction, state })
    } catch (err) {
      flash = err
    } finally {
      updating = null
    }
  }
</script>

{#if nextActions}
  <h3 class="next">{I18n('next action')}:</h3>
  <section>
    <div class="actions">
      {#each nextActions as nextAction}
        {#if nextAction.waiting}
          <span class="action {nextAction.state}">{@html I18n(nextAction.text, nextAction)}</span>
        {:else}
          <button
            class="action {nextAction.state}"
            on:click={() => updateState(nextAction.state)}
            disabled={updating}
          >
            {#if updating === nextAction.state}
              <Spinner />
            {/if}
            {@html I18n(nextAction.text, nextAction)}</button>
        {/if}
      {/each}
    </div>
  </section>
  <Flash state={flash} />
  <div class="info">
    <!-- there should be only one action with info at a time, thus the absence of separating markups -->
    {#each nextActions as nextAction}
      {#if nextAction.acceptRequestOneWay}
        <div class="check-list">
          <p>{i18n('before_accepting_general')}</p>
          <ul>
            {#if nextAction.selling}
              <li>{i18n('how_much')}</li>
            {/if}
            <li>{i18n('where_and_when')}</li>
          </ul>
        </div>
      {/if}
      {#if nextAction.waitingConfirmationOneWay}
        <p>{i18n('book_displayed_unavailable')}</p>
        <p>{@html I18n('waiting_confirmation_one_way', nextAction)}</p>
      {/if}
      {#if nextAction.acceptRequestLending}
        <div class="check-list">
          <p>{i18n('before_accepting_general')}</p>
          <ul>
            <li>{i18n('where_and_when')}</li>
            <li>{i18n('how_long', nextAction)}</li>
          </ul>
        </div>
        <strong>{I18n('advice:')}</strong> {i18n('before_accepting_lending_advice')}
      {/if}
      {#if nextAction.i18nKey}<p>{@html i18n(nextAction.i18nKey, nextAction)}</p>{/if}
    {/each}
  </div>
{:else}
  <p class="finished">{I18n('transaction_finished')}</p>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  @import '#transactions/scss/transactions_commons';
  .actions{
    padding: 0.5em 1em;
    text-align: center;
    /* Small screens */
    @media screen and (max-width: $very-small-screen){
      @include display-flex(column, center, stretch);
      .action{
        width: 100%;
        max-width: 20em;
        padding: 0.5em;
        margin: 0.5em;
        &:not(.waiting){
          white-space: nowrap;
        }
      }
    }
    /* Large screens */
    @media screen and (min-width: $very-small-screen){
      @include display-flex(row, baseline, center);
    }
  }
  .action{
    margin-inline-start: 0.2em;
    margin-inline-end: 0.2em;
  }
  .accepted, .confirmed, .returned{
    @include tiny-button($success-color);
  }
  .declined, .archived{
    @include tiny-button($grey);
  }
  .waiting, .finished{
    color: $grey;
    text-align: center;
  }
  .info{
    text-align: center;
    padding-inline-start: 1em;
    padding-inline-end: 1em;
    color: #666;
    > p:first-child{
      padding-block-start: 1em;
    }
    .check-list{
      padding-block-end: 0;
      p{
        text-align: start;
        padding: 1em 1em 0;
      }
    }
    ul{
      padding: 0 1em 1em 2em;
    }
    li{
      color: #444;
      text-align: start;
      list-style-type: disc;
    }
  }
  h3, .finished{
    padding-block-start: 0.8em;
    padding-inline-start: 1em;
    font-size: 1em;
    opacity: 0.5;
    @include sans-serif;
    margin: 0;
  }
</style>
