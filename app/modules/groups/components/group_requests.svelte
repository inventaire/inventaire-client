<script>
  import Spinner from '#components/spinner.svelte'
  import UserGroupRequestLi from '#groups/components/user_group_request_li.svelte'
  import { serializeGroupUser } from '#groups/lib/groups'
  import Flash from '#lib/components/flash.svelte'
  import { getUsersByIds } from '#users/users_data'
  import { pluck } from 'underscore'

  export let group

  let flash, users = []

  const usersIds = pluck(group.requested, 'user')

  const waitingForUsers = getUsersByIds(usersIds)
    .then(res => users = Object.values(res).map(serializeGroupUser(group)))
    .catch(err => flash = err)
</script>

{#await waitingForUsers}
  <Spinner center={true} />
{:then}
  <ul>
    {#each users as user}
      <UserGroupRequestLi bind:group {user} />
    {/each}
  </ul>
{/await}

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  ul{
    background-color: white;
    padding: 0.5rem;
    @include radius;
  }
</style>
