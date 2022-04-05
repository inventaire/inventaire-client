<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import ItemsByTransaction from './items_by_transaction.svelte'

  export let itemsByCategorie
  export let itemsToDisplay
  export let headers
  export let categorie
  const { customIcon, label, backgroundColor } = headers
  const itemsByTransactions = {
    giving: [],
    lending: [],
    selling: [],
    inventorying: [],
  }

  let someItems = false

  const dispatchByTransaction = item => {
    const transaction = item.transaction
    if (!someItems && transaction) someItems = true
    itemsByTransactions[transaction].push(item)
  }
  const filterDocsToDisplay = () => itemsToDisplay = itemsByCategorie

  itemsByCategorie.forEach(dispatchByTransaction)
</script>
<div style="background-color:{backgroundColor}" class="items-list">
  <div class="header">
    <div class="categorie-title-wrapper">
      <h3 class="categorie-title">
        {@html icon(customIcon)}
        {I18n(label)}
      </h3>
    </div>
    {#if someItems}
      {#if categorie !== 'personal'}
        <button
          class="map-button"
          on:click={filterDocsToDisplay}
        >
          {@html icon('map-marker')}{I18n('show on map')}
        </button>
      {/if}
    {:else}
      <div class="empty-list">
        {i18n('nothing here')}
      </div>
    {/if}
  </div>
  {#if someItems}
    <div class="items-list-per-transactions">
      {#each Object.keys(itemsByTransactions) as transaction}
        <ItemsByTransaction
          itemsByTransaction={itemsByTransactions[transaction]}
          {transaction}
        />
      {/each}
    </div>
  {/if}
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .items-list-per-transactions{
    max-height: 15em;
    overflow-y: auto;
    margin-top: 0.3em;
  }
  .categorie-title{
    @include sans-serif;
    margin: 0;
    font-size: 1.2em;
  }
  .categorie-title-wrapper{
    @include display-flex(row, center, flex-start);
    :global(.fa){
      color: $dark-grey;
      width: 2em;
    }
  }
  .header{
    @include display-flex(row, center, space-between);
    margin-bottom: 0.5em;
  }
  .empty-list{
    padding: 0 0.5em;
    color: lighten($grey, 15%);
  }
  .items-list{
    @include radius;
    padding: 0.5em;
    margin-bottom: 0.5em;
    /* background-color is defined by backgroundColor*/
  }
  .map-button{
    padding: 0.5em;
    @include selected-button-color($grey)
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .tiny-button{
      padding: 0.3em;
    }
  }
</style>
