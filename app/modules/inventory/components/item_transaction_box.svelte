<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import { uniqueId } from 'underscore'
  import { transactionsData } from '#inventory/lib/transactions_data'

  export let item, flash, large = false

  const { pathname, restricted } = item
  let { currentTransaction } = item

  const menuId = uniqueId('item-transaction-box-')

  async function updateTransaction (newTransactionData) {
    const previousTransaction = currentTransaction
    item.currentTransaction = currentTransaction = newTransactionData
    try {
      await app.request('items:update', {
        items: [ item ],
        attribute: 'transaction',
        value: newTransactionData.id,
      })
    } catch (err) {
      item.currentTransaction = currentTransaction = previousTransaction
      flash = err
    }
  }
</script>

<div class="item-card-box">
  {#if restricted}
    <a href={pathname} on:click={loadInternalLink}>
      {@html icon(currentTransaction.icon)}
      {i18n(currentTransaction.labelShort)}
    </a>
  {:else}
    <Dropdown
      buttonTitle={i18n('Select transaction mode')}
      clickOnContentShouldCloseDropdown={true}
      alignButtonAndDropdownWidth={large}
      >
      <!-- Not using a dynamic class to avoid `no-unused-selector` warnings -->
      <!-- See See https://github.com/sveltejs/svelte/issues/1594 -->
      <div
        slot="button-inner"
        class:giving={currentTransaction.id === 'giving'}
        class:lending={currentTransaction.id === 'lending'}
        class:selling={currentTransaction.id === 'selling'}
        class:inventorying={currentTransaction.id === 'inventorying'}
        >
        <div class="icon">
          {@html icon(currentTransaction.icon)}
          {#if !large}{@html icon('caret-down')}{/if}
        </div>
        {#if large}
          <div class="rest">
            <span>{I18n(currentTransaction.labelShort)}</span>
            {@html icon('caret-down')}
          </div>
        {/if}
      </div>
      <div slot="dropdown-content">
        <label for={menuId}>{I18n('available for')}:</label>
        <ul id={menuId} role="menu">
          {#each Object.values(transactionsData) as transaction}
            <li>
              <button
                role="menuitem"
                class:selected={transaction.id === currentTransaction.id}
                on:click={() => updateTransaction(transaction)}
                >
                {@html icon(transaction.icon)} {i18n(transaction.label)}
              </button>
            </li>
          {/each}
        </ul>
      </div>
    </Dropdown>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#inventory/scss/item_card_box';
  [slot="button-inner"]{
    .icon{
      color: white;
    }
    &.giving{
      .icon{
        background-color: $giving-color;
      }
    }
    &.lending{
      .icon{
        background-color: $lending-color;
      }
    }
    &.selling{
      .icon{
        background-color: $selling-color;
      }
    }
    &.inventorying{
      .icon{
        background-color: $inventorying-color;
      }
    }
  }
  label{
    text-align: start;
    font-size: 1rem;
    padding: 0.2em 0.5em;
  }
  [role="menuitem"]{
    text-align: start;
    width: 100%;
    padding: 0.5em;
    &.selected{
      background-color: #666;
      &, :global(.fa){
        color: white;
      }
    }
    &:not(.selected){
      @include bg-hover(white);
    }
  }
</style>
