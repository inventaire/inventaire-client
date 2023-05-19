<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import ItemsByTransaction from './items_by_transaction.svelte'
  import { createEventDispatcher } from 'svelte'
  import Spinner from '#components/spinner.svelte'
  import { groupBy } from 'underscore'
  import { onChange } from '#lib/svelte/svelte'

  const dispatch = createEventDispatcher()

  export let categoryItems = []
  export let itemsOnMap
  export let headers
  export let category
  export let displayCover
  export let waitingForItems

  const { customIcon, label, backgroundColor } = headers

  const itemsByTransactionsBase = {
    giving: [],
    lending: [],
    selling: [],
    inventorying: [],
  }

  let itemsByTransactions = itemsByTransactionsBase

  function dispatchByTransaction () {
    const categoryItemsByTransactions = groupBy(categoryItems, 'transaction')
    itemsByTransactions = Object.assign({}, itemsByTransactionsBase, categoryItemsByTransactions)
  }

  const showItemsOnMap = () => {
    itemsOnMap = categoryItems
    dispatch('showItemsOnMap')
  }

  let itemOnMap = false
  const showItemOnMap = itemOnMap => {
    if (itemOnMap) itemsOnMap = [ itemOnMap ]
    dispatch('showItemsOnMap')
  }

  let emptyList = !isNonEmptyArray(categoryItems)

  $: onChange(categoryItems, dispatchByTransaction)

  $: {
    showItemOnMap(itemOnMap)
  }
</script>

<div style:background-color={backgroundColor} class="items-list">
  <div class="header">
    <div class="category-title-wrapper">
      <h3
        class="category-title"
        class:emptyList
      >
        {@html icon(customIcon)}
        {I18n(label)}
      </h3>
    </div>
    {#if categoryItems.length > 0}
      {#if category !== 'personal'}
        <button
          class="map-button"
          on:click={showItemsOnMap}
        >
          {@html icon('map-marker')}{I18n('show on map')}
        </button>
      {/if}
    {:else}
      <div class="emptyList">
        {i18n('nothing here')}
      </div>
    {/if}
  </div>
  {#await waitingForItems}
    <Spinner center={true} />
  {:then}
    {#if categoryItems.length > 0}
      <div class="items-list-per-transactions">
        {#each Object.entries(itemsByTransactions) as [ transaction, transactionItems ]}
          <ItemsByTransaction
            {transaction}
            {transactionItems}
            {displayCover}
            bind:itemOnMap
          />
        {/each}
      </div>
    {/if}
  {/await}
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .items-list-per-transactions{
    max-height: 15em;
    overflow-y: auto;
    margin-top: 0.3em;
  }
  .category-title{
    @include sans-serif;
    margin: 0;
    font-size: 1.1em;
    margin-right: 1em;
  }
  .category-title-wrapper{
    @include display-flex(row, center, flex-start);
    :global(.fa){
      color: $dark-grey;
      width: 2em;
    }
  }
  .header{
    @include display-flex(row, center, space-between);
  }
  .emptyList{
    padding: 0 0.5em;
    color: lighten($grey, 15%);
    font-size: 1em;
    :global(.fa){
      color: lighten($grey, 15%);
    }
  }
  .items-list{
    @include radius;
    padding: 0.5em;
    margin-bottom: 0.5em;
    /* background-color is defined by backgroundColor */
  }
  .map-button{
    @include tiny-button($light-grey, black);
  }
</style>
