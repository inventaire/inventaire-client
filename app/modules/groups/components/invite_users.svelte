<script lang="ts">
  import { debounce } from 'underscore'
  import { icon } from '#app/lib/icons'
  import { onChange } from '#app/lib/svelte/svelte'
  import Spinner from '#components/spinner.svelte'
  import UserGroupRequestLi from '#groups/components/user_group_request_li.svelte'
  import { serializeGroupUser } from '#groups/lib/groups'
  import { I18n } from '#user/lib/i18n'
  import { searchUsers } from '#users/users_data'

  export let group

  let searchText, waitingForUsers
  let users

  async function searchAndDisplayUsers () {
    if (!searchText) return
    waitingForUsers = searchUsers(searchText)
    users = (await waitingForUsers).map(serializeGroupUser(group))
  }
  const lazySearchUsers = debounce(searchAndDisplayUsers, 300)

  $: onChange(searchText, lazySearchUsers)
</script>

<div class="filter-wrapper">
  <input
    id="usersSearch"
    type="text"
    placeholder="{I18n('search users')}..."
    bind:value={searchText}
  />
  {@html icon('search')}
</div>

{#await waitingForUsers}
  <Spinner center={true} />
{:then}
  {#if users}
    <ul>
      {#each users as user (user._id)}
        <UserGroupRequestLi bind:group {user} />
      {:else}
        <li class="no-user-found">{I18n('no user found')}</li>
      {/each}
    </ul>
  {/if}
{/await}

<style lang="scss">
  @use "#general/scss/utils";
  $filter-padding-top: 0.5em;
  $filter-icon-margin: 0.6em;

  .filter-wrapper{
    min-height: 2.5em;
    padding-block-start: $filter-padding-top;
    position: relative;
    max-width: 20em;
    margin: 0 auto 1em;
    :global(.fa-search){
      position: absolute;
      inset-block-start: $filter-padding-top + $filter-icon-margin;
      inset-inline-end: $filter-icon-margin;
      color: $grey;
    }
    input{
      position: absolute;
      inset-block-start: $filter-padding-top;
      margin: 0;
      @include radius;
    }
  }
  ul{
    background-color: white;
    padding: 0.5rem;
    @include radius;
    max-height: 20em;
    overflow-y: auto;
  }
  .no-user-found{
    text-align: center;
    opacity: 0.8;
    font-style: italic;
  }
</style>
