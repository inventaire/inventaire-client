<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon, loadInternalLink } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'

  export let doc

  const { transaction, picture: userPicture, username, cover, id, title } = doc

  const pathname = `/items/${id}`

  const findBestTitle = () => {
    const context = i18n(`${transaction}_personalized`, { username })
    return `${title} - ${context}`
  }
</script>

<a
  class="showItem"
  href={pathname}
  on:click={loadInternalLink}
  title={findBestTitle()}
>
  <img src={imgSrc(cover, 64)} alt={findBestTitle()} />
  {#if userPicture}
    <div class="right">
      <img src={imgSrc(userPicture, 64)} alt={username} />
    </div>
  {/if}
  <div class="icon-wrapper">
    {@html icon(transaction, transaction)}
  </div>
  <p class="username">{username}</p>
</a>
