<!-- TODO: merge with #map/components/user_marker.svelte -->
<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { SelectInventoryOnClick } from '#users/components/lib/navs_helpers'

  export let doc
  const { username, picture } = doc
  const pathname = `/users/${username}`

  const onClick = SelectInventoryOnClick({ type: 'user', doc })
</script>

<a
  href={pathname}
  on:click={onClick}
  title="{username} - {I18n('user')}"
  class="objectMarker userMarker"
>
  <div
    class="picture"
    style="background-image: url({imgSrc(picture, 100)})"
  />
  <p class="username label">
    {username}
  </p>
</a>
