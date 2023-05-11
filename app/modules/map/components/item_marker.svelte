<script>
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon, isOpenedOutside } from '#lib/utils'

  export let item

  const {
    transaction,
    pathname,
    personalizedTitle,
    user,
    image: cover,
  } = item

  const {
    username,
    picture: userPicture,
  } = user

  let showItemModal
  function showItem (e) {
    if (isOpenedOutside(e)) return
    showItemModal = true
    e.preventDefault()
  }
</script>

<div class="objectMarker itemMarker">
  <a
    class="showItem"
    href={pathname}
    on:click={showItem}
    title={personalizedTitle}
  >
    <img class="marker-img" src={imgSrc(cover, 64)} alt={personalizedTitle} />
    {#if userPicture}
      <div class="right">
        <img class="marker-img" src={imgSrc(userPicture, 64)} alt={username} />
      </div>
    {/if}
    <div class="icon-wrapper">
      {@html icon(transaction, transaction)}
    </div>
    <p class="username">{username}</p>
  </a>
</div>

<ItemShowModal bind:item bind:showItemModal />
