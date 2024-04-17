<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { icon } from '#app/lib/icons'
  import { isOpenedOutside } from '#app/lib/utils'
  import ItemShowModal from '#inventory/components/item_show_modal.svelte'
  import { i18n } from '#user/lib/i18n'

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
          loading="lazy"
        />
      {/if}
    </div>
    <img
      src={imgSrc(userPicture, 64, 64)}
      alt={username}
      loading="lazy"
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
    inline-size: 2.2em;
  }
  img{
    @include radius;
    margin-inline-end: 0.3em;
    flex: 0 0 auto;
    max-block-size: 2.5em;
    max-inline-size: 4em;
  }
  .user-info{
    min-inline-size: 5em;
    flex: 0 0 auto;
  }
  .details{
    max-block-size: 2.5em;
    flex: 1 0 0;
    overflow: hidden;
    line-height: 1.2em;
    margin-inline-start: 0.5em;
  }
  .distance{
    color: $grey;
  }
  .map-button{
    @include tiny-button($light-grey, black);
    padding: 0.5em;
    margin-inline-end: 0.2em;
  }
</style>
