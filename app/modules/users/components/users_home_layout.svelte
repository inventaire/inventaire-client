<script lang="ts">
  import { writable } from 'svelte/store'
  import { debounce } from 'underscore'
  import app from '#app/app'
  import { resizeObserver } from '#app/lib/components/actions/resize_observer'
  import { getViewportHeight } from '#app/lib/screen'
  import { onChange } from '#app/lib/svelte/svelte'
  import GroupProfile from '#groups/components/group_profile.svelte'
  import type { SerializedGroup } from '#groups/lib/groups'
  import { mainUser } from '#user/lib/main_user'
  import NetworkUsersNav from '#users/components/network_users_nav.svelte'
  import PublicUsersNav from '#users/components/public_users_nav.svelte'
  import UserProfile from '#users/components/user_profile.svelte'
  import UsersHomeNav from '#users/components/users_home_nav.svelte'
  import { type SerializedUser } from '#users/lib/users'

  export let user: SerializedUser = null
  export let group: SerializedGroup = null
  export let shelf = null
  export let section: 'user' | 'public' | 'network' = null
  export let profileSection: 'inventory' | 'listings' = null
  export let showShelfFollowers = null
  export let showUserFollowers = null

  const { loggedIn } = app.user

  // The focus store is used to determine which component should claim the focus
  // It plays the role of an event bus between the layout children component
  // to allow url navigation and scroll within the layout
  const focusedSection = writable({ type: null })

  if (shelf) {
    $focusedSection = { type: 'shelf' }
  } else if (user) {
    $focusedSection = { type: 'user' }
  } else if (group) {
    $focusedSection = { type: 'group' }
  }

  $: if (user) {
    if ('deleted' in user && user.deleted) app.execute('show:error:missing')
  }

  if (user && user._id === app.user._id) section = 'user'

  function onSectionChange () {
    if (section) {
      if (section === 'user') {
        user = $mainUser
      } else {
        shelf = null
      }
    }
  }
  $: onChange(section, onSectionChange)

  let wrapperEl, innerEl

  function onElementResize () {
    if (wrapperEl && innerEl) {
      const minHeight = Math.max(innerEl.clientHeight, getViewportHeight())
      // Set a minimun height so that the view doesn't jump up when the content height suddenly shrinks
      // Known cases:
      // - when then content is shorter, such as when a filter is picked and only a few items are displayed
      // - during a transition between two views, such as when a shelf is closed
      wrapperEl.style.minHeight = `${minHeight}px`
    }
  }

  function onFocus () {
    const pathname = `users/${section}`
    app.navigate(pathname, { pageSectionElement: wrapperEl })
  }

  const debouncedOnFocus = debounce(onFocus, 200, true)

  $: if ($focusedSection.type == null) debouncedOnFocus()
</script>

<div class="wrapper" bind:this={wrapperEl}>
  <div
    id="usersHomeLayout"
    bind:this={innerEl}
    use:resizeObserver={{ onElementResize }}
  >
    {#if loggedIn}
      <UsersHomeNav bind:section />
    {/if}

    {#if section === 'network'}
      <NetworkUsersNav {focusedSection} />
    {:else if section === 'public'}
      <PublicUsersNav {focusedSection} />
    {:else if user}
      <!-- Use #key to prevent reusing the previous UserProfile component,
           which might have been initialized with another user -->
      {#key user}
        <UserProfile
          {user}
          bind:shelf
          bind:profileSection
          {focusedSection}
          standalone={true}
          {showShelfFollowers}
          {showUserFollowers}
        />
      {/key}
    {:else if group}
      {#key group}
        <GroupProfile
          {group}
          {profileSection}
          {focusedSection}
          standalone={true}
        />
      {/key}
    {/if}
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";

  .wrapper{
    transition: min-height 0.5s 5s ease;
  }

  #usersHomeLayout{
    background-color: white;
    min-height: 100vh;

    /* Large screens */
    @media screen and (width >= $small-screen){
      padding: 0.5em;
    }
  }
</style>
