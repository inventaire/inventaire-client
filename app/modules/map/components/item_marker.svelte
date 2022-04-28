<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { icon, isOpenedOutside } from '#lib/utils'
  import { i18n } from '#user/lib/i18n'

  export let doc
  export let displayCover

  const { transaction, userPicture, username, cover, id, title } = doc

  const showItem = e => {
    e.stopPropagation()
    if (!isOpenedOutside(e)) {
      // Todo: go back to entity page on closing item modal
      app.execute('show:item:byId', id)
      e.preventDefault()
    }
  }

  const pathname = `/items/${id}`

  const findBestTitle = () => {
    const context = i18n(`${transaction}_personalized`, { username })
    return `${title} - ${context}`
  }
</script>
<a
  class="showItem"
  on:click={showItem}
  href="{pathname}"
  title="{findBestTitle()}"
>
  {#if displayCover}
    <img src="{imgSrc(cover, 64)}" alt="{findBestTitle()}">
  {/if}
  {#if userPicture}
    <div class="right">
      <img src="{imgSrc(userPicture, 64)}" alt="{username}">
    </div>
  {/if}
  <div class="icon-wrapper">
    {@html icon(transaction, transaction)}
  </div>
  <p class="username">{username}</p>
</a>
