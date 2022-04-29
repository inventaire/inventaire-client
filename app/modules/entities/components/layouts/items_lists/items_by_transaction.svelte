<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { icon } from '#lib/utils'
  import { transactionsData } from '#inventory/lib/transactions_data'
  import ItemPreview from './item_preview.svelte'

  export let itemsByTransaction, transaction, itemOnMap, displayCover

  const showItemOnMap = item => itemOnMap = item
</script>

{#if isNonEmptyArray(itemsByTransaction)}
  <div class="transaction-box {transaction}" title="{transaction}">
    {@html icon(transactionsData[transaction].icon)}
    <span class="label">{transaction}</span>
  </div>
  <div class="items-preview">
    {#each itemsByTransaction as item}
      <ItemPreview
        {item}
        {displayCover}
        on:showItemOnMap="{showItemOnMap(item)}"
      />
    {/each}
  </div>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  .transaction-box{
    width: max-content;
    @include display-flex(row, center, flex-start);
    height: 2em;
    padding: 0 1em 0 0.5em;
    @include radius;
    :global(.fa){
      margin: 0 0.3em;
    }
  }
  .items-preview{
    margin-bottom: 0.5em;
  }
  .giving{
    background-color: lighten($giving-color, 8%);
  }
  .lending{
    background-color: lighten($lending-color, 12%);
  }
  .selling{
    background-color: lighten($selling-color, 15%);
  }
  .inventorying{
    background-color: lighten($inventorying-color, 12%);
  }
</style>
