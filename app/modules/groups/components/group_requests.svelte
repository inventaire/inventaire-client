<script lang="ts">
  import { pluck } from 'underscore'
  import Flash from '#app/lib/components/flash.svelte'
  import Spinner from '#components/spinner.svelte'
  import UserGroupRequestLi from '#groups/components/user_group_request_li.svelte'
  import { serializeGroupUser } from '#groups/lib/groups'
  import { getUsersByIds } from '#users/users_data'

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
  @use "#general/scss/utils";
  ul{
    background-color: white;
    padding: 0.5rem;
    @include radius;
  }
</style>
