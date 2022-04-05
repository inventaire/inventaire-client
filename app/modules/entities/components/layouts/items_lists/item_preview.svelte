<script>
  import { isOpenedOutside } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  export let item

  const {
    id,
    details,
    transaction,
    userPicture,
    username,
    distanceFromMainUser,
    owner
  } = item

  const notOwner = owner !== app.user.id
  const url = `/items/${id}`

  const showItem = e => {
    e.stopPropagation()
    if (!isOpenedOutside(e)) {
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }
</script>
<div class="show-item"
  on:click={showItem}
>
  <a
    class="items-link"
    href={url}
    title="{i18n(`${transaction}_personalized`, { username })}"
  >
    <img
      src="{imgSrc(userPicture, 64, 64)}"
      alt="{username}"
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
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .items-link{
    @include bg-hover(white, 10%);
    @include display-flex(row, center, flex-start);
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
</style>
