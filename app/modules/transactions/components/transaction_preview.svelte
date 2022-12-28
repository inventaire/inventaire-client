<script>
  import { icon, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getTransactionStateText, addTransactionDerivedData } from '#transactions/lib/transactions'

  export let transaction, onItem = false

  const { pathname, mainUserRead, transactionMode } = addTransactionDerivedData(transaction)
  const { requester } = transaction.snapshot
  const transactionStateText = getTransactionStateText({ transaction })
</script>

<a
  href={pathname}
  on:click|stopPropagation={loadInternalLink}
  class="transaction-preview"
  class:unread={!mainUserRead}
  class:on-item={onItem}
>
  <!-- snapshot data are always more meaningful than the item data
  as they reflect the state of the item - especially the transaction -
  when the transaction started -->
  <div
    class="icon-wrapper"
    class:giving={transactionMode.id === 'giving'}
    class:lending={transactionMode.id === 'lending'}
    class:selling={transactionMode.id === 'selling'}
    class:inventorying={transactionMode.id === 'inventorying'}
  >
    {@html icon(transactionMode.icon)}
  </div>
  {#if onItem}
    <div class="profile-pic">
      {#if requester.picture}
        <img src={imgSrc(requester.picture, 48)} alt={requester.username} />
      {/if}
    </div>
    <span class="context-text">{@html transactionStateText}</span>
  {:else}
    <!-- <div class="profile-pic">
      {#if other.picture}
        <img src={imgSrc(other.picture, 48)} alt={other.username}>
      {/if}
    </div>
    <div class="text">
      <span class="title">{entity.title}</span>
      <span class="context">{other.username}</span>
    </div>
    <div class="item-pic">
      {#if entity.image}
        <img src={imgSrc(entity.image, 48)} alt={entity.title}>
      {/if}
    </div> -->
  {/if}
  <!-- <div class="flags">
    {PARTIAL 'notifications:unread_flag'}
  </div> -->
</a>

<style lang="scss">
  @import '#general/scss/utils';
  .transaction-preview{
    height: $user-box-heigth;
    @include display-flex(row, center);
    @include bg-hover(white);
    &.on-item{
      @include bg-hover($off-white);
    }
    &:not(.on-item){
      @include bg-hover(white);
    }
  }
  .icon-wrapper{
    align-self: stretch;
    width: 1.6em;
    max-width: 1.6em;
    min-width: 1.6em;
    flex: 0 0 1.6em;
    @include display-flex(row, center, center);
    :global(.fa){
      color: white;
    }
  }
  .context-text{
    margin-inline-start: 0.5em;
  }
  .giving{
    background-color: $giving-color;
  }
  .lending{
    background-color: $lending-color;
  }
  .selling{
    background-color: $selling-color;
  }
  .inventorying{
    background-color: $inventorying-color;
  }
</style>
