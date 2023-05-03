<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon, loadInternalLink } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'

  export let item

  const { transaction, picture: userPicture, username, cover, id, title } = item

  const pathname = `/items/${id}`
  const context = i18n(`${transaction}_personalized`, { username })
  const personalizedTitle = `${title} - ${context}`
</script>

<div class="objectMarker itemMarker">
  <a
    class="showItem"
    href={pathname}
    on:click={loadInternalLink}
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
