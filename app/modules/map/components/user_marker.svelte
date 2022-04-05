<script>
  import { I18n, i18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let doc
  const { username, _id, picture } = doc
  const isMainUser = app.user.id === _id
  let itemsCount = 0
  const pathname = `/inventory/${username}`
</script>
<a href="{pathname}" title="{username} - {I18n('user')}">
  <div
    class="picture"
    style="background-image: url({imgSrc(picture, 100)})"
  />
  <p class="username label">
    {username}
  </p>
</a>
{#if isMainUser}
  <a id="showPositionPicker">{@html icon('pencil')}</a>
{:else}
  <div class="items-count" title="{i18n('num_books', { smart_count: itemsCount })}">{@html icon('book')} {itemsCount}</div>
{/if}
