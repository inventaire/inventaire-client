<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon, isOpenedOutside } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'

  export let item
  export let displayCover

  const dispatch = createEventDispatcher()

  const {
    id,
    details,
    transaction,
    picture: userPicture,
    username,
    distanceFromMainUser,
    owner,
    cover,
    title
  } = item

  const notOwner = owner !== app.user.id
  const url = `/items/${id}`

  const showItem = e => {
    e.stopPropagation()
    if (!isOpenedOutside(e)) {
      // TODO: on item modal close, it should navigate back to entity page
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }

  const showItemOnMap = () => dispatch('showItemOnMap')
</script>
<div
  class="show-item"
  on:click={showItem}
>
  <a
    class="items-link"
    href={url}
    title={i18n(`${transaction}_personalized`, { username })}
  >
    {#if displayCover}
      <img
        src={imgSrc(cover, 64)}
        alt={title}
      >
    {/if}
    <img
      src={imgSrc(userPicture, 64, 64)}
      alt={username}
    >
    <div class="user-info">
      <p class="username">
        {username}
      </p>
      {#if distanceFromMainUser && notOwner}
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
  {#if distanceFromMainUser && notOwner}
    <button
      class="map-button"
      on:click|stopPropagation={showItemOnMap}
      title={i18n('show user on map')}
    >
      {@html icon('map-marker')}
    </button>
  {/if}
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .items-link{
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
