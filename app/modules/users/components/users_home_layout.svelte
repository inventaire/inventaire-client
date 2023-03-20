<script>
  import UsersHomeNav from '#users/components/users_home_nav.svelte'
  import UserProfile from '#users/components/user_profile.svelte'
  import GroupProfile from '#groups/components/group_profile.svelte'
  import NetworkUsersNav from '#users/components/network_users_nav.svelte'
  import PublicUsersNav from '#users/components/public_users_nav.svelte'
  import { serializeUser } from '#users/lib/users'
  import app from '#app/app'

  export let user, group, section, subsection = 'inventory'

  const { loggedIn } = app.user

  if (user?._id === app.user.id) section = 'user'

  $: if (user) user = serializeUser(user)
</script>

<div id="usersHomeLayout">
  {#if loggedIn}
    <UsersHomeNav bind:section />
  {/if}

  {#if section === 'user'}
    <UserProfile user={app.user.toJSON()} section={subsection} />
  {:else if section === 'network'}
    <NetworkUsersNav />
  {:else if section === 'public'}
    <PublicUsersNav />
  {:else if user}
    <UserProfile {user} section={subsection} />
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
