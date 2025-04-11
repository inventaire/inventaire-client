<script lang="ts">
  import { tick, createEventDispatcher } from 'svelte'
  import { API } from '#app/api/api'
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { screen } from '#app/lib/components/stores/screen'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import preq from '#app/lib/preq'
  import { BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import { getISODay, getISOTime } from '#app/lib/time'
  import { userContent } from '#app/lib/user_content'
  import ActorFollowers from '#app/modules/activitypub/components/actor_followers.svelte'
  import Modal from '#components/modal.svelte'
  import UserInventory from '#inventory/components/user_inventory.svelte'
  import UsersListings from '#listings/components/users_listings.svelte'
  import { mainUserHasAdminAccess } from '#modules/user/lib/main_user'
  import { I18n, i18n } from '#user/lib/i18n'
  import ProfileNav from '#users/components/profile_nav.svelte'
  import UserProfileButtons from '#users/components/user_profile_buttons.svelte'
  import { setInventoryStats, type SerializedUser } from '../lib/users'

  export let user: SerializedUser
  export let shelf = null
  export let profileSection = null
  export let groupId = null
  export let standalone = false
  export let focusedSection
  export let showShelfFollowers = null
  export let showUserFollowers = null

  const {
    _id: userId,
    username,
    bio,
    picture,
    created,
    fediversable,
  } = user

  let flash, userProfileEl, followersCount, waitingForFollowersCount

  let itemsCount, shelvesCount

  setInventoryStats(user)
    .then(() => {
      ;({ itemsCount, shelvesCount } = user)
    })
    .catch(err => flash = err)

  async function onFocus () {
    if (!userProfileEl) await tick()
    shelf = null
    navigateToSection()
  }

  function navigateToSection () {
    // Let app.navigate scroll to the page top when UserProfile
    // is already at the top itself (standalone mode), to make the UsersHomeNav visible
    const pageSectionElement = standalone ? null : userProfileEl
    let pathname, title, rss
    if (showUserFollowers) return
    if (profileSection === 'inventory') {
      pathname = user.inventoryPathname
      title = `${username} - ${i18n('Inventory')}`
      rss = API.feeds('user', userId)
    } else if (profileSection === 'listings') {
      pathname = user.listingsPathname
      title = `${username} - ${I18n('lists')}`
    } else if ($focusedSection.type === 'shelf') {
      pathname = `/shelves/${shelf._id}`
      title = `${username} - ${i18n('Inventory')}`
    } else {
      title = username
      pathname = user.pathname
      rss = API.feeds('user', userId)
    }
    const metadata = {
      title,
      description: bio,
      image: picture,
      rss,
    }
    app.navigate(pathname, { pageSectionElement, metadata })
  }

  if (fediversable) {
    waitingForFollowersCount = getFollowersCount()
  }

  async function getFollowersCount () {
    const res = await preq.get(API.activitypub.followers({ name: username }))
    followersCount = res.totalItems
  }

  function showFollowersModal () {
    showUserFollowers = true
    app.navigate(`/users/${username}/followers`)
  }

  function closeFollowersModal () {
    showUserFollowers = false
    navigateToSection()
  }

  $: if ($focusedSection.type === 'user') onFocus()

  const dispatch = createEventDispatcher()
  const bubbleUpComponentEvent = BubbleUpComponentEvent(dispatch)
</script>

<div class="full-user-profile">
  <div class="user-profile" bind:this={userProfileEl}>
    <div class="user-card">
      <div class="avatar-wrapper">
        <img class="avatar" src={imgSrc(picture, 150, 150)} alt="{username} avatar" />
      </div>
      <div class="info">
        <h2 class="respect-case">
          <span class="username">{username}</span>
          {#if $screen.isSmallerThan('$smaller-screen')}
            {#if !standalone}
              <button class="unselect-profile" on:click={() => dispatch('unselectProfile')}>{@html icon('times')}</button>
            {/if}
          {:else if mainUserHasAdminAccess()}
            <div class="admin-info">
              <span class="identifier">{userId}</span>
              <span class="creation-date" title={`${I18n('created')}: ${getISOTime(created)}`}>
                {getISODay(created)}
              </span>
            </div>
          {/if}
        </h2>
        <ul class="data">
          {#if itemsCount != null}
            <li class="inventory-length">
              <span>{@html icon('book')}{i18n('books')}</span>
              <span class="count">{itemsCount}</span>
            </li>
          {/if}
          {#if shelvesCount != null}
            <li class="show-shelves-list shelves-length">
              <span>{@html icon('server')}{i18n('shelves')}</span>
              <span class="count">{shelvesCount}</span>
            </li>
          {/if}
          {#if fediversable}
            {#await waitingForFollowersCount then}
              {#if followersCount > 0}
                <li class="followers-count">
                  <a href="{username}/followers" on:click={showFollowersModal}>
                    <span>{@html icon('address-book')}{i18n('followers')}</span>
                    <span class="count">{followersCount}</span>
                  </a>
                </li>
              {/if}
            {/await}
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
    <UserProfileButtons
      {user}
      bind:flash
      displayUnselectButton={!standalone}
      on:unselectProfile={bubbleUpComponentEvent}
    />
  </div>

  <Flash state={flash} />

  <ProfileNav {user} bind:profileSection {focusedSection} />

  {#if profileSection === 'listings'}
    <UsersListings usersIds={[ user._id ]} />
  {:else}
    <UserInventory
      {user}
      {groupId}
      {focusedSection}
      bind:selectedShelf={shelf}
      bind:flash
      {showShelfFollowers}
    />
  {/if}
</div>

{#if showUserFollowers}
  <Modal on:closeModal={closeFollowersModal}
  >
    <ActorFollowers
      actorName={username}
      standalone={true}
    />
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .full-user-profile{
    // Make sure it is possible to scroll to put the user profile at the top of the viewport
    min-height: 100vh;
  }
  h2{
    @include display-flex(row, baseline, flex-start);
    margin: 0;
  }
  .user-profile{
    background-color: #eee;
    @include display-flex(row);
    margin: 0.5em 0;
    // Also include .unselect-profile in UserProfileButtons
    :global(.unselect-profile){
      width: 2.5rem;
      padding: 0.5rem 0;
      :global(.fa){
        @include shy;
        font-size: 2rem;
      }
    }
    .unselect-profile{
      align-self: flex-start;
      margin-inline-start: auto;
    }
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
  .admin-info{
    margin: 0 0.5rem;
    @include identifier;
  }
  .data{
    @include display-flex(row, flex-start);
    color: #666;
    margin-block-end: 0.5em;
    li{
      margin-inline-end: 1em;
    }
  }
  .inventory-length, .show-shelves-list, .followers-count{
    :global(.fa){
      padding-inline-end: 1.5em;
    }
    .count{
      padding-inline-start: 0.3em;
    }
  }
  .followers-count a{
    cursor: pointer;
    color: #666;
  }
  .bio-wrapper{
    @include radius;
    margin-block-end: 2em;
    max-width: 50em;
    overflow: auto;
  }

  /* Large screens */
  @media screen and (width >= $smaller-screen){
    .user-card{
      min-height: 9em;
    }
    .avatar-wrapper{
      width: 9em;
      flex: 0 0 auto;
    }
    .info{
      flex: 1 0 0;
      padding: 0.8em 1em 0;
    }
  }

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
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
      margin: 0 0.5em;
      text-align: center;
    }
    .data{
      li{
        margin: 0 0 0.5em;
      }
      flex-direction: column;
      align-items: center;
    }
    .bio-wrapper{
      max-height: 10em;
      margin: 0.5em;
    }
  }

  /* Small screens */
  @media screen and (width < $small-screen){
    .admin-info{
      display: none;
    }
  }
</style>
