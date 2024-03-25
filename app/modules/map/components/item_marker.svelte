<script>
  import { createEventDispatcher } from 'svelte'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon } from '#lib/icons'
  import { isOpenedOutside } from '#lib/utils'

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

  const dispatch = createEventDispatcher()

  function showItem (e) {
    if (isOpenedOutside(e)) return
    dispatch('showItem')
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
    <img
      class="marker-img"
      src={imgSrc(cover, 64)}
      alt={personalizedTitle}
      loading="lazy"
    />
    {#if userPicture}
      <div class="right">
        <img
          class="marker-img"
          src={imgSrc(userPicture, 64)}
          alt={username}
          loading="lazy"
        />
      </div>
    {/if}
    <div class="icon-wrapper">
      {@html icon(transaction, transaction)}
    </div>
    <p class="username">{username}</p>
  </a>
</div>
