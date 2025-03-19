<script lang="ts">
  import { createEventDispatcher } from 'svelte'
  import app from '#app/app'
  import assert_ from '#app/lib/assert_types'
  import { screen } from '#app/lib/components/stores/screen'
  import { icon } from '#app/lib/icons'
  import { loadInternalLink } from '#app/lib/utils'
  import Modal from '#components/modal.svelte'
  import Spinner from '#components/spinner.svelte'
  import LeafletMap from '#map/components/leaflet_map.svelte'
  import Marker from '#map/components/marker.svelte'
  import UserMarker from '#map/components/user_marker.svelte'
  import ShelfEditor from '#shelves/components/shelf_editor.svelte'
  import { i18n, I18n } from '#user/lib/i18n'
  import { user as mainUser } from '#user/user_store'
  import { updateRelationStatus } from '#users/lib/relations'
  import { serializeUser } from '#users/lib/users'

  export let user
  export let flash
  export let displayUnselectButton = true

  const { username, isMainUser, distanceFromMainUser } = serializeUser(user)

  let showShelfCreator, showUserOnMap

  let relationState = user.status

  let previousRelationState, waitingForUpdate
  const makeRequest = async ({ action, newRelationState }) => {
    previousRelationState = relationState
    try {
      relationState = newRelationState
      waitingForUpdate = await updateRelationStatus(user, action)
    } catch (err) {
      relationState = previousRelationState
      flash = err
    }
  }

  const unfriend = () => {
    confirmAction('unfriend', () => {
      makeRequest({ action: 'unfriend', newRelationState: 'none' })
    })
  }
  const cancelFriendRequest = () => {
    makeRequest({ action: 'cancel', newRelationState: 'none' })
  }
  const acceptFriendRequest = () => {
    makeRequest({ action: 'accept', newRelationState: 'friends' })
  }
  const discardFriendRequest = () => {
    makeRequest({ action: 'discard', newRelationState: 'none' })
  }
  const sendFriendRequest = () => {
    makeRequest({ action: 'request', newRelationState: 'userRequested' })
  }

  function confirmAction (actionLabel: string, action: (() => void), warningText?: string) {
    assert_.string(actionLabel)
    assert_.function(action)
    const confirmationText = I18n(`${actionLabel}_confirmation`, { username })
    app.execute('ask:confirmation', { confirmationText, warningText, action })
  }
  const dispatch = createEventDispatcher()
</script>

<div class="profile-buttons" class:has-unselect-button={displayUnselectButton}>
  {#if displayUnselectButton && $screen.isLargerThan('$smaller-screen')}
    <button class="unselect-profile" on:click={() => dispatch('unselectProfile')}>{@html icon('times')}</button>
  {/if}
  {#if isMainUser}
    <a
      class="editProfile action tiny-button light-blue"
      href="/settings/profile"
      on:click={loadInternalLink}
    >
      {@html icon('pencil')}
      {I18n('edit profile')}
    </a>
    <a
      class="addItems action tiny-button light-blue"
      href="/add/scan"
      title={I18n('title_add_layout')}
      on:click={loadInternalLink}
    >
      {@html icon('plus')} {I18n('add books')}
    </a>
    <button
      class="action tiny-button light-blue"
      on:click={() => showShelfCreator = true}
    >
      {@html icon('plus')}{I18n('create shelf')}
    </button>
  {:else}
    {#if distanceFromMainUser}
      <button
        class="show-user-on-map tiny-button light-blue"
        on:click={() => showUserOnMap = true}
      >
        {@html icon('map-marker')}
        <span class="label">
          {i18n('km_away_from_you', { distance: distanceFromMainUser })}
        </span>
      </button>
    {/if}
    {#await waitingForUpdate}
      <Spinner />
    {:then}
      {#if relationState === 'friends'}
        <button
          on:click={unfriend}
          class="unfriend action tiny-button"
          title={I18n('unfriend')}
        >
          {@html icon('minus')}<span class="label"> {I18n('unfriend')}</span>
        </button>
      {:else if relationState === 'userRequested'}
        <button
          on:click={cancelFriendRequest}
          class="cancel action tiny-button"
          title={I18n('cancel friend request')}
        >
          {@html icon('ban')}<span class="label"> {I18n('cancel request')}</span>
        </button>
      {:else if relationState === 'otherRequested'}
        <button
          on:click={acceptFriendRequest}
          class="accept action tiny-button light-blue"
          title={I18n('accept friend request')}
        >
          {@html icon('check')}<span class="label"> {I18n('confirm')}</span>
        </button>
        <button
          on:click={discardFriendRequest}
          class="discard action tiny-button"
          title={I18n('discard friend request')}
        >
          {@html icon('minus')}<span class="label"> {I18n('decline')}</span>
        </button>
      {:else}
        <button
          on:click={sendFriendRequest}
          class="request action tiny-button light-blue"
          title={I18n('send friend request')}
        >
          {@html icon('plus')}<span class="label"> {I18n('add friend')}</span>
        </button>
      {/if}
    {/await}
  {/if}
</div>

{#if showShelfCreator}
  <Modal on:closeModal={() => showShelfCreator = false}>
    <ShelfEditor
      shelf={{}}
      inGlobalModal={false}
      on:shelfEditorDone={() => showShelfCreator = false}
    />
  </Modal>
{/if}

{#if showUserOnMap}
  <Modal size="large" on:closeModal={() => showUserOnMap = false}>
    <div class="map">
      <LeafletMap bounds={[ user.position, $mainUser.position ]}>
        <Marker latLng={user.position}>
          <UserMarker doc={user} on:select={() => showUserOnMap = false} />
        </Marker>
        <Marker latLng={$mainUser.position}>
          <UserMarker doc={$mainUser} on:select={() => app.navigateAndLoad($mainUser.pathname)} />
        </Marker>
      </LeafletMap>
    </div>
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .profile-buttons{
    @include display-flex(column, stretch, flex-start);
    a, .tiny-button{
      line-height: 1;
      padding: 0.5em;
      min-width: 10em;
      margin: 0 0 1em 1em;
      :global(.fa){
        margin-inline-end: auto;
      }
    }
    flex: 0 0 auto;
    .action{
      @include display-flex(row, center, flex-start);
    }
  }
  .unselect-profile{
    // Other rules are set in UserProfile
    align-self: flex-end;
  }
  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .profile-buttons{
      margin-inline-start: auto;
      &.has-unselect-button{
        margin: 0 0.5em;
      }
      &:not(.has-unselect-button){
        margin: 0.5em;
      }
    }
    .action{
      margin: 0 0.5em;
    }
  }

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .profile-buttons{
      flex-direction: column;
      margin: 0.5em;
    }
    .show-user-on-map{
      margin-block-end: 1em;
    }
    .action{
      margin: 0.5em 0;
    }
  }

  .map{
    height: 80vh;
  }
</style>
