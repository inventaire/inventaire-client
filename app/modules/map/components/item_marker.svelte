<script>
  import { isOpenedOutside, icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { i18n } from '#user/lib/i18n'

  export let doc

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
  {#if cover}
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
