<script lang="ts">
  import { pluck } from 'underscore'
  import Flash from '#app/lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import GroupMemberLi from '#groups/components/group_member_li.svelte'
  import { serializeGroupUser } from '#groups/lib/groups'
  import { getUsersByIds } from '#users/users_data'

  export let group

  let flash, users

  const usersIds = pluck(group.admins.concat(group.members), 'user')

  const waitingForRequestingUsers = getUsersByIds(usersIds)
    .then(res => users = Object.values(res).map(serializeGroupUser(group)))
    .catch(err => flash = err)
</script>

{#await waitingForRequestingUsers}
  <Spinner center={true} />
{:then}
  <ul>
    {#each users as user}
      <GroupMemberLi bind:group {user} />
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
