<script>
  import { onMount, tick } from 'svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon } from '#lib/icons'
  import { loadInternalLink } from '#lib/utils'
  import { getTransactionStateText, serializeTransaction } from '#transactions/lib/transactions'

  export let transaction
  export let selectedTransaction = null
  export let onItem = false

  const { pathname, transactionMode } = serializeTransaction(transaction)
  const { entity, requester, other } = transaction.snapshot
  const transactionStateText = getTransactionStateText({ transaction })

  let mainUserRead
  $: ({ mainUserRead } = serializeTransaction(transaction))

  function onClick (e) {
    if (onItem) {
      loadInternalLink(e)
    } else {
      selectedTransaction = transaction
    }
  }
  let transactionPreviewEl
  onMount(async () => {
    if (selectedTransaction === transaction) {
      await tick()
      transactionPreviewEl?.scrollIntoView({ block: 'start', inline: 'nearest', behavior: 'smooth' })
    }
  })
</script>

<a
  href={pathname}
  on:click|stopPropagation|preventDefault={onClick}
  class="transaction-preview"
  class:unread={!mainUserRead}
  class:on-item={onItem}
  class:selected={transaction._id === selectedTransaction?._id}
  bind:this={transactionPreviewEl}
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
        <img src={imgSrc(requester.picture, 48)} alt={requester.username} loading="lazy" />
      {/if}
    </div>
    <span class="context-text">{@html transactionStateText}</span>
  {:else}
    <div class="profile-pic">
      {#if other.picture}
        <img src={imgSrc(other.picture, 48)} alt={other.username} />
      {/if}
    </div>
    <div class="text">
      <span class="title">{entity?.title || ''}</span>
      <span class="context">{other.username}</span>
    </div>
    <div class="item-pic">
      {#if entity?.image}
        <img src={imgSrc(entity.image, 48)} alt="" />
      {/if}
    </div>
  {/if}
  <div class="flags">
    {#if !mainUserRead}
      <div class="unread-flag">{@html icon('circle')}</div>
    {/if}
  </div>
</a>

<style lang="scss">
  @import "#general/scss/utils";
  .transaction-preview{
    height: $user-box-heigth;
    @include display-flex(row, center, flex-start);
    &.on-item{
      @include bg-hover($off-white);
    }
    &:not(.on-item){
      @include bg-hover(white);
    }
    &.unread{
      background-color: $unread-color;
    }
    &.selected{
      box-shadow: 0 1px 3px 2px rgba(0, 0, 0, 10%) inset;
      background-color: $light-grey;
      .unread-flag{
        display: none;
      }
    }
  }
  .text{
    flex: 1 1 auto;
    max-height: 3em;
    overflow: hidden;
  }
  span{
    display: block;
    padding-inline-start: 0.2em;
    text-overflow: ellipsis;
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
  .unread-flag{
    @include display-flex(row, center, center);
    margin-inline-start: 0.3em;
    font-size: 0.8em;
    opacity: 0.8;
    align-self: center;
    flex: 0 0 auto;
    padding: 0.2em;
    :global(.fa){
      color: $light-blue;
    }
  }
  .profile-pic, .item-pic{
    // hidding overflowing alt text
    overflow: hidden;
  }
  .profile-pic{
    flex: 0 0 $user-box-heigth;
  }
  .profile-pic, .profile-pic img{
    width: $user-box-heigth;
    height: $user-box-heigth;
  }
  .item-pic, .item-pic img{
    flex: 0 0 auto;
    max-width: $user-box-heigth;
    max-height: $user-box-heigth;
    overflow: hidden;
  }
  .flags{
    flex: 0 0 1em;
  }
</style>
