<script>
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon, isOpenedOutside } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'

  export let item
  export let displayCover

  const dispatch = createEventDispatcher()

  const {
    pathname,
    details,
    distanceFromMainUser,
    personalizedTitle,
    user,
    image: cover,
    title,
    mainUserIsOwner,
  } = item

  const {
    username,
    picture: userPicture,
  } = user

  const showItemOnMap = () => dispatch('showItemOnMap')

  let showItemModal
  function showItem (e) {
    if (isOpenedOutside(e)) return
    showItemModal = true
    e.preventDefault()
  }
</script>

<div class="show-item">
  <a
    class="items-link"
    href={pathname}
    on:click={showItem}
    title={personalizedTitle}
  >
    <div class="cover-wrapper">
      {#if displayCover && cover}
        <img
          src={imgSrc(cover, 64)}
          alt={title}
        />
      {/if}
    </div>
    <img
      src={imgSrc(userPicture, 64, 64)}
      alt={username}
    />
    <div class="user-info">
      <p class="username">
        {username}
      </p>
      {#if distanceFromMainUser && !mainUserIsOwner}
        <p class="distance">
          {i18n('km_away', { distance: distanceFromMainUser })}
        </p>
      {/if}
    </div>
    {#if details}
      <p class="details">
        {details}
      </p>
    {/if}
  </a>
  {#if distanceFromMainUser && !mainUserIsOwner}
    <button
      class="map-button"
      on:click|stopPropagation={showItemOnMap}
      title={i18n('Show user on map')}
    >
      {@html icon('map-marker')}
    </button>
  {/if}
</div>

<ItemShowModal bind:item bind:showItemModal />

<style lang="scss">
  @import "#general/scss/utils";
  .items-link{
    display: block;
    @include display-flex(row, center, flex-start);
    @include bg-hover(white, 10%);
    @include radius;
  }
  .show-item{
    @include display-flex(row, center, space-between);
    background-color: white;
    cursor: pointer;
    padding: 0.2em 0.5em;
  }
  .cover-wrapper{
    // Force width so that items without cover image are also aligned
    width: 2.2em;
  }
  img{
    @include radius;
    margin-right: 0.3em;
    flex: 0 0 auto;
    max-height: 2.5em;
    max-width: 4em;
  }
  .user-info{
    min-width: 5em;
    flex: 0 0 auto;
  }
  .details{
    max-height: 2.5em;
    flex: 1 0 0;
    overflow: hidden;
    line-height: 1.2em;
    margin-left: 0.5em;
  }
  .distance{
    color: $grey;
  }
  .map-button{
    @include tiny-button($light-grey, black);
    padding: 0.5em;
    margin-right: 0.2em;
  }
</style>
