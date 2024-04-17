<script lang="ts">
  import app from '#app/app'
  import { autosize } from '#app/lib/components/actions/autosize'
  import Flash from '#app/lib/components/flash.svelte'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { isOpenedOutside } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import ItemMixedBox from '#inventory/components/item_mixed_box.svelte'
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { postTransactionRequest } from '#transactions/lib/helpers'
  import { i18n, I18n } from '#user/lib/i18n'

  export let item
  export let user

  const { _id: itemId, transaction, details = '', snapshot, entity } = item
  const suggestedTextKey = `item_request_text_suggestion_${transaction}`
  const { username } = user

  let message = i18n(suggestedTextKey, { username })

  let sendingRequest, flash
  async function sendItemRequest () {
    try {
      sendingRequest = postTransactionRequest({ itemId, message })
      await sendingRequest
      app.execute('show:transaction', transaction._id)
    } catch (err) {
      flash = err
    }
  }

  let showItemModal
  function showItem (e) {
    if (isOpenedOutside(e)) return
    showItemModal = true
    e.preventDefault()
  }
</script>

<div class="request-item-modal">
  <div class="header">
    <a class="item" href={item.pathname} on:click={showItem}>
      <div class="cover">
        {#if snapshot['entity:image']}
          <img src={imgSrc(snapshot['entity:image'], 100)} alt={snapshot['entity:title']} />
        {/if}
      </div>
      <span class="title">{snapshot['entity:title']}</span>
      <span class="entity">{entity}</span>
      <p class="details">{details}</p>
    </a>
    <div class="user">
      <ItemMixedBox {item} />
    </div>
  </div>

  <textarea
    id="message"
    name="request-item"
    bind:value={message}
    use:autosize
  />

  <button class="button success radius bold" on:click={sendItemRequest} disabled={sendingRequest != null}>
    {#await sendingRequest}
      <Spinner />
    {:then}
      {@html icon('send')}
    {/await}
    {I18n('send request')}
  </button>

</div>

<Flash state={flash} />

<ItemShowModal bind:item bind:showItemModal />

<style lang="scss">
  @import "#general/scss/utils";

  .request-item-modal{
    @include display-flex(column, center, center);
  }
  .header{
    width: 100%;
    @include display-flex(row, center, space-between);
    margin-block-end: 1em;
  }
  .item{
    flex: 1 1 auto;
    @include display-flex(column, center, center);
    .entity{
      opacity: 0.5;
    }
  }
  .user{
    width: 16em;
    @include display-flex(column, stretch, flex-start);
  }
  textarea{
    @include radius;
  }
</style>
