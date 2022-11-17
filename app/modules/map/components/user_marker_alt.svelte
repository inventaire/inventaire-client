<!-- TODO: merge with #map/components/user_marker.svelte -->
<script>
  import { I18n } from '#user/lib/i18n'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { SelectInventoryOnClick } from '#users/components/lib/navs_helpers'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { showMainUserPositionPicker } from '#map/lib/map'

  export let doc
  const { _id, username, picture } = doc
  const pathname = `/users/${username}`
  const isMainUser = _id === app.user.id

  const onClick = SelectInventoryOnClick({ type: 'user', doc })
</script>

<div class="objectMarker userMarker">
  <a
    href={pathname}
    on:click={onClick}
    title="{username} - {I18n('user')}"
  >
    <div
      class="picture"
      style="background-image: url({imgSrc(picture, 100)})"
    />
    <p class="username label">
      {username}
    </p>
  </a>
  {#if isMainUser}
    <button
      id="showPositionPicker"
      on:click={showMainUserPositionPicker}
    >
      {@html icon('pencil')}
    </button>
  {/if}
</div>
