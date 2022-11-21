<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon, loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { userContent } from '#lib/handlebars_helpers/user_content'
  import { setDistance } from '#users/lib/users'
  import Modal from '#components/modal.svelte'
  import ShelfEditor from '#shelves/components/shelf_editor.svelte'
  import assert_ from '#lib/assert_types'
  import Flash from '#lib/components/flash.svelte'
  import { updateRelationStatus } from '#users/lib/relations'
  import Spinner from '#components/spinner.svelte'
  import User from '#users/models/user'
  import { screen } from '#lib/components/stores/screen'

  export let user

  if (!user.mainUser) setDistance(user)

  const { username, bio, picture, inventoryLength, shelvesCount, mainUser, distanceFromMainUser } = user

  let showShelfCreator, flash

  let relationState
  if (user.friends) relationState = 'friends'
  else if (user.userRequested) relationState = 'userRequested'
  else if (user.otherRequested) relationState = 'otherRequested'
  else relationState = 'none'

  let previousRelationState, waitingForUpdate
  const makeRequest = async ({ action, newRelationState }) => {
    previousRelationState = relationState
    try {
      relationState = newRelationState
      waitingForUpdate = await updateRelationStatus({ user, action })
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

  function confirmAction (actionLabel, action, warningText) {
    assert_.string(actionLabel)
    assert_.function(action)
    const confirmationText = I18n(`${actionLabel}_confirmation`, { username })
    app.execute('ask:confirmation', { confirmationText, warningText, action })
  }

  function showUserOnMap () {
    const userModel = new User(user)
    app.execute('show:models:on:map', [ userModel, app.user ])
  }
</script>

<div class="user-profile">
  <div class="user-card">
    <div class="avatar-wrapper">
      <img class="avatar" src={imgSrc(picture, 150, 150)} alt="{username} avatar">
    </div>
    <div class="info">
      <h2 class="username respect-case">{username}</h2>
      <ul class="data">
        {#if inventoryLength != null}
          <li class="inventoryLength">
            <span>{@html icon('book')}{i18n('books')}</span>
            <span class="count">{inventoryLength}</span>
          </li>
        {/if}
        {#if shelvesCount != null}
          <li class="showShelvesList shelvesLength">
            <span>{@html icon('server')}{i18n('shelves')}</span>
            <span class="count">{shelvesCount}</span>
          </li>
        {/if}
      </ul>
      {#if $screen.isLargerThan('$smaller-screen')}
        {#if bio}
          <p class="bio-wrapper">{@html userContent(bio)}</p>
        {/if}
      {/if}
    </div>
  </div>

  {#if $screen.isSmallerThan('$smaller-screen')}
    {#if bio}
      <p class="bio-wrapper">{@html userContent(bio)}</p>
    {/if}
  {/if}

  <div class="profile-buttons">
    {#if mainUser}
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
        href="/add/scan" title={I18n('title_add_layout')}
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
          class="showUserOnMap tiny-button light-blue"
          on:click={showUserOnMap}
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
</div>

<Flash state={flash} />

{#if showShelfCreator}
  <Modal
    on:closeModal={() => showShelfCreator = false}
  >
    <ShelfEditor
      inGlobalModal={false}
      on:shelfEditorDone={() => showShelfCreator = false}
    />
  </Modal>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  .user-profile{
    background-color: #eee;
    @include display-flex(row);
    margin: 0.5em 0;
  }
  .user-card{
    flex: 1;
    @include display-flex(row);
  }
  .avatar{
    background-color: #eee;
  }
  .info{
    position: relative;
  }
  .username{
    @include sans-serif;
    margin: 0;
  }
  .profile-buttons{
    margin: 0.5em;
    @include display-flex(column, stretch, center);
    a, button{
      line-height: 1;
      padding: 0.5em;
      min-width: 10em;
      margin: 0 0 1em 1em;
      :global(.fa){
        margin-right: auto;
      }
    }
    flex: 0 0 auto;
    .action{
      @include display-flex(row, center, flex-start);
    }
  }
  .data{
    @include display-flex(row, flex-start);
    color: #666;
    margin-bottom: 0.5em;
    li{
      margin-right: 1em;
    }
  }
  .inventoryLength, .showShelvesList{
    .count{
      padding-left: 0.5em;
    }
  }
  .bio-wrapper{
    @include radius;
    margin-bottom: 2em;
    max-width: 50em;
    overflow: auto;
  }

  /*Large screens*/
  @media screen and (min-width: $smaller-screen) {
    .avatar-wrapper{
      flex: 0 0 auto;
    }
    .profile-buttons{
      margin-left: auto;
    }
    .action{
      margin: 0 0.5em;
    }
    .info{
      flex: 1 0 0;
      padding: 0.8em 1em;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .user-profile{
      @include display-flex(column, center, center);
    }
    .user-card{
      flex-wrap: wrap;
      align-self: stretch;
      margin: 0 0.5em;
    }
    .avatar-wrapper{
      flex: 1 0 0;
      max-width: 30%;
      min-width: 4em;
    }
    .info{
      flex: 2 0 0;
      min-width: min(10em, 90vw);
    }
    .username{
      text-align: center;
    }
    .profile-buttons{
      margin-bottom: 0.5em;
      flex-direction: column;
    }
    .showUserOnMap{
      margin-bottom: 1em;
    }
    .data{
      li {
        margin: 0 0 0.5em 0;
      }
      flex-direction: column;
      align-items: center;
    }
    .bio-wrapper{
      max-height: 10em;
      margin: 0.5em;
    }
    .action{
      margin: 0.5em 0;
    }
  }
</style>
