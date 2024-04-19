<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { isOpenedOutside, loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { getItemPathname, getItemWithUser } from '#inventory/lib/items'
  import { attachLinkedDocs, getTransactionContext } from '#transactions/lib/transactions'
  import { getUserBasePathname } from '#users/lib/users'

  export let transaction

  const { transactionMode } = transaction
  const { entity, owner } = transaction.snapshot
  const itemPathname = getItemPathname(transaction.item)

  let context, ownerPathname
  const waitingForLinkedDocs = attachLinkedDocs(transaction)
    .then(() => {
      context = getTransactionContext(transaction)
      ownerPathname = getUserBasePathname(transaction.docs.owner.username)
    })

  let flash, item
  let showItemModal = false
  async function showItem (e) {
    if (isOpenedOutside(e)) return
    try {
      item = item || await getItemWithUser(transaction.item)
      showItemModal = true
    } catch (err) {
      flash = err
    }
  }
</script>

<div class="header">
  <div class="facts">
    <a
      class="item"
      href={itemPathname}
      title={entity.title}
      on:click={showItem}
    >
      <div class="cover">
        {#if entity.image}
          <img src={imgSrc(entity.image, 100)} alt="" />
        {/if}
      </div>
      <div class="data">
        <h4 class="title">{entity.title}</h4>
        <div class="authors">
          {#if entity.authors}
            {entity.authors}
          {/if}
        </div>
      </div>
    </a>
    {#await waitingForLinkedDocs}
      <Spinner />
    {:then}
      <div class="context {transactionMode.id}">
        {@html icon(transactionMode.icon)}
        {@html context}
        {#if owner.picture}
          <a
            href={ownerPathname}
            class="owner"
            title={owner.username}
            on:click={loadInternalLink}
          >
            <img src={imgSrc(owner.picture, 48)} alt={owner.username} />
          </a>
        {/if}
      </div>
    {/await}
  </div>
  <Flash state={flash} />
</div>

<ItemShowModal bind:item bind:showItemModal />

<style lang="scss">
  @import '#general/scss/utils';
  .header{
    @include radius;
    @include radius-top;
    background-color: white;
    padding-block-end: 1em;
  }
  .item{
    @include display-flex(row, center, center);
    @include bg-hover(white);
  }
  .cover{
    flex: 0 0 auto;
    max-width: 5em;
    overflow: hidden;
    img{
      padding-inline-end: 0.2em;
    }
  }
  .data{
    margin-inline-start: 0.2em;
  }
  .title{
    font-size: 1.2em;
    // in case the title is very long
    max-height: 5em;
    overflow: hidden;
  }
  .property-value{
    display: none;
  }
  .context{
    flex: 0 0 auto;
    :global(.fa){
      color: white;
      width: auto;
      padding: 0.5em;
    }
    &.giving{
      :global(.fa){
        background-color: $giving-color;
      }
    }
    &.lending{
      :global(.fa){
        background-color: $lending-color;
      }
    }
    &.selling{
      :global(.fa){
        background-color: $selling-color;
      }
    }
  }
  .header :global(.fa), .owner img{
    @include radius;
  }
  .owner{
    margin-inline-start: 0.2em;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .facts{
      padding: 1em;
      @include display-flex(row, center, space-around, wrap);
    }
    .context{
      margin-block-start: 1em;
      img{
        max-width: 15vw;
      }
    }
  }
  /* Large screens */
  @media screen and (min-width: $small-screen){
    .facts{
      @include display-flex(row, center, space-between);
      padding: 1em;
    }
  }
</style>
