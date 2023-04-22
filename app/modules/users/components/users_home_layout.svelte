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
  import { getViewportHeight } from '#lib/screen'
  import { resizeObserver } from '#lib/components/actions/resize_observer'
  import { onChange } from '#lib/svelte/svelte'

  export let user = null
  export let group = null
  export let shelf = null
  export let section = null
  export let profileSection = null

  const { loggedIn } = app.user

  const focusStore = writable({})
  setContext('focus-store', focusStore)

  if (shelf) $focusStore = { type: 'shelf' }
  else if (user) $focusStore = { type: 'user' }
  else if (group) $focusStore = { type: 'group' }

  $: if (user) user = serializeUser(user)

  if (user?._id === app.user.id) section = 'user'
  function onSectionChange () {
    if (section && section !== 'user') shelf = null
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
  <div
    id="usersHomeLayout"
    bind:this={innerEl}
    use:resizeObserver={{ onElementResize }}
  >
    {#if loggedIn}
      <UsersHomeNav bind:section />
    {/if}

    {#if section === 'network'}
      <NetworkUsersNav />
    {:else if section === 'public'}
      <PublicUsersNav />
    {:else if user}
      <UserProfile
        {user}
        bind:shelf
        bind:profileSection
        standalone={true} />
    {:else if group}
      <GroupProfile
        {group}
        {profileSection}
        standalone={true}
      />
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
