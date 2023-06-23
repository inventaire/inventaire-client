<script>
  import { I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { guessInitialTransaction } from '#inventory/components/lib/item_creation_helpers'
  import { transactionsDataFactory } from '#inventory/lib/transactions_data'

  export let transaction, showDescription = false

  transaction = guessInitialTransaction(transaction)
</script>

<fieldset>
  <legend>
    <p class="title">{I18n('transaction')}</p>
    {#if showDescription}
      <p class="description">{I18n("I have it and it's available for:")}</p>
    {/if}
  </legend>
  {#each Object.values(transactionsDataFactory()) as { name, creationLabel, icon: iconName }}
    <label class={name} class:selected={transaction === name}>
      <input
        type="radio"
        bind:group={transaction}
        name="transaction"
        value={name} />
      {@html icon(iconName)}
      {I18n(creationLabel)}
    </label>
  {/each}
</fieldset>

<style lang="scss">
  @import "#general/scss/utils";

  fieldset{
    @include display-flex(row);
  }

  label{
    color: $dark-grey;
    background-color: #eee;
    font-size: 1rem;
    padding: 0.8rem;
    margin: 0.2em;
    border: 2px solid $light-grey;
    border-radius: 5px;
    @include sans-serif;
    font-weight: normal;
    @include transition(border-color, 0.3s);
    :global(.fa){
      margin-inline-start: 0.5em;
      @include transition(color, 0.3s);
    }
    &.selected, &:hover{
      background-color: white;
    }
  }

  .giving{
    &.selected, &:hover{
      border-color: $giving-color;
      :global(.fa){
        color: $giving-color;
      }
    }
  }
  .lending{
    &.selected, &:hover{
      border-color: $lending-color;
      :global(.fa){
        color: $lending-color;
      }
    }
  }
  .selling{
    &.selected, &:hover{
      border-color: $selling-color;
      :global(.fa){
        color: $selling-color;
      }
    }
  }
  .inventorying{
    &.selected, &:hover{
      border-color: $inventorying-color;
      :global(.fa){
        color: $inventorying-color;
      }
    }
  }

  /* Small screens */
  @media screen and (max-width: $small-screen){
    fieldset{
      flex-direction: column;
    }
  }
</style>
