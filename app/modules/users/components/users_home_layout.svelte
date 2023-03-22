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
</script>

<!-- TODO: prevent content height jump when navigating within the page -->
<div id="usersHomeLayout">
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
    <GroupProfile {group} />
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";

  #usersHomeLayout{
    background-color: white;
    // Set a minimun height so that when a filter is picked and only a few items
    // are displayed as a result, the view doesn't jump up
    min-height: 100vh;

    /* Large screens */
    @media screen and (min-width: $small-screen){
      padding: 0.5em;
    }
  }
</style>
