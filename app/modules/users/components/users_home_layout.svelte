<script>
  import UsersHomeNav from '#users/components/users_home_nav.svelte'
  import UserProfile from '#users/components/user_profile.svelte'
  import GroupProfile from '#groups/components/group_profile.svelte'
  import NetworkUsersNav from '#users/components/network_users_nav.svelte'
  import PublicUsersNav from '#users/components/public_users_nav.svelte'
  import { serializeUser } from '#users/lib/users'
  import app from '#app/app'
  import { setContext } from 'svelte'
  import { writable } from 'svelte/store'
  import { onChange } from '#lib/svelte/svelte'
  import { getViewportHeight } from '#lib/screen'
  import { resizeObserver } from '#lib/components/actions/resize_observer'

  export let user, group, shelf, section, subsection = 'inventory'

  const { loggedIn } = app.user

  if (user?._id === app.user.id) section = 'user'

  const focusStore = writable({})
  setContext('focus-store', focusStore)

  if (shelf) $focusStore = { type: 'shelf', doc: shelf }
  // When starting from a user or a group, no need to scroll
  // as it's already pretty much at the top
  // if (user) $focusStore = { type: 'user', doc: user }
  // if (group) $focusStore = { type: 'group', doc: group }

  $: if (user) user = serializeUser(user)

  function onSectionChange () {
    if (section !== 'user') shelf = null
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
</script>

<div class="wrapper" bind:this={wrapperEl}>
  <div id="usersHomeLayout" bind:this={innerEl} use:resizeObserver={{ onElementResize }}>
    {#if loggedIn}
      <UsersHomeNav bind:section />
    {/if}

    {#if section === 'user' && !shelf}
      <UserProfile user={app.user.toJSON()} section={subsection} />
    {:else if section === 'network'}
      <NetworkUsersNav />
    {:else if section === 'public'}
      <PublicUsersNav />
    {:else if user}
      <UserProfile {user} {shelf} section={subsection} />
    {:else if group}
      <GroupProfile {group} section={subsection} />
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
    @media screen and (min-width: $small-screen){
      padding: 0.5em;
    }
  }
</style>
