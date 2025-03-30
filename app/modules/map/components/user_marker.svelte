<!-- TODO: merge with #map/components/user_marker.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import app from '#app/app'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { isOpenedOutside } from '#app/lib/utils'
  import UserPositionPicker from '#settings/components/user_position_picker.svelte'
  import { I18n } from '#user/lib/i18n'

  export let doc
  const { _id, username, picture } = doc
  const pathname = `/users/${username}`
  const isMainUser = _id === app.user.id

  const dispatch = createEventDispatcher()

  function select (e) {
    if (!isOpenedOutside(e)) {
      dispatch('select', { type: 'user', doc })
      e.preventDefault()
    }
  }

  export async function showMainUserPositionPicker () {
    app.layout.showChildComponent('svelteModal', UserPositionPicker, {
      props: {
        showPositionPicker: true,
      },
    })
  }
</script>

<div class="objectMarker userMarker">
  <a
    href={pathname}
    on:click={select}
    title="{username} - {I18n('user')}"
  >
    <div
      class="picture"
      style:background-image="url({imgSrc(picture, 100)})"
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
