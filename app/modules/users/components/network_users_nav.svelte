<script lang="ts">
  import app from '#app/app'
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { loadInternalLink } from '#app/lib/utils'
  import Modal from '#components/modal.svelte'
  import GroupProfile from '#groups/components/group_profile.svelte'
  import { getUserGroups } from '#groups/lib/groups_data'
  import { getNetworkItems } from '#inventory/lib/queries'
  import { i18n, I18n } from '#user/lib/i18n'
  import InviteByEmail from '#users/components/invite_by_email.svelte'
  import PaginatedSectionItems from '#users/components/paginated_section_items.svelte'
  import UserProfile from '#users/components/user_profile.svelte'
  import UsersHomeSectionList from '#users/components/users_home_section_list.svelte'
  import { getFriends } from '../lib/relations'

  export let focusedSection

  let flash, users, groups

  getFriends()
    .then(friends => users = friends)
    .catch(err => flash = err)

  getUserGroups()
    .then(userGroups => groups = userGroups)
    .catch(err => flash = err)

  let showUsersMenu, showGroupsMenu, showInviteFriendByEmail

  let selectedUser, selectedGroup
  function onSelectUser (e) {
    selectedUser = e.detail.doc
    selectedGroup = null
    $focusedSection = { type: 'user' }
    e.preventDefault()
  }
  function unselect () {
    selectedUser = null
    selectedGroup = null
    $focusedSection = { type: null }
  }
  function onSelectGroup (e) {
    selectedUser = null
    selectedGroup = e.detail.doc
    $focusedSection = { type: 'group' }
    e.preventDefault()
  }
</script>

<div class="lists">
  <div class="list-wrapper">
    <div class="list-label-wrapper">
      <h2 class="list-label">{I18n('friends')}</h2>
      {#if !showUsersMenu}
        <button
          class="menu-toggler"
          on:click={() => showUsersMenu = true}
          aria-controls="userMenu"
        >
          {@html icon('plus')} {i18n('add friend')}
        </button>
      {/if}
      <div id="userMenu" class="buttons">
        {#if showUsersMenu}
          <button on:click={() => showInviteFriendByEmail = true}
          >
            {@html icon('envelope')}
            {I18n('invite')}
          </button>
          <button on:click={app.Execute('show:users:search')}
          >
            {@html icon('search')}
            {I18n('search')}
          </button>
          <button on:click={app.Execute('show:users:nearby')}
          >
            {@html icon('map-marker')}
            {I18n('find on map')}
          </button>
        {/if}
      </div>
    </div>
    {#if users}
      <UsersHomeSectionList
        docs={users}
        type="users"
        on:select={onSelectUser}
      />
    {/if}
  </div>

  <div class="list-wrapper">
    <div class="list-label-wrapper">
      <h2 class="list-label">{I18n('groups')}</h2>
      {#if !showGroupsMenu}
        <button
          class="menu-toggler"
          on:click={() => showGroupsMenu = true}
          aria-controls="groupMenu"
        >
          {@html icon('plus')} {i18n('add group')}
        </button>
      {/if}
      <div class="buttons groupMenu">
        {#if showGroupsMenu}
          <button on:click={app.Execute('show:groups:search')}
          >
            {@html icon('search')}
            {I18n('search')}
          </button>
          <button on:click={app.Execute('show:groups:nearby')}
          >
            {@html icon('map-marker')}
            {I18n('find on map')}
          </button>
          <a
            href="/network/groups/create"
            on:click={loadInternalLink}
          >
            {@html icon('plus')}
            {I18n('create')}
          </a>
        {/if}
      </div>
    </div>
    {#if groups}
      <UsersHomeSectionList docs={groups} type="groups" on:select={onSelectGroup} />
    {/if}
  </div>
</div>

{#if selectedUser}
  <!-- Recreate component when selectedUser changes, see https://svelte.dev/docs#template-syntax-key -->
  {#key selectedUser}
    <UserProfile user={selectedUser} {focusedSection} on:unselectProfile={unselect} />
  {/key}
{:else if selectedGroup}
  {#key selectedGroup}
    <GroupProfile group={selectedGroup} {focusedSection} on:unselectGroup={unselect} />
  {/key}
{:else}
  <PaginatedSectionItems sectionRequest={getNetworkItems} />
{/if}

{#if showInviteFriendByEmail}
  <Modal on:closeModal={() => showInviteFriendByEmail = false}>
    <InviteByEmail />
  </Modal>
{/if}

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  @import "#users/scss/users_home_section_navs";
  .list-wrapper{
    @include display-flex(column);
  }
  .list-label-wrapper{
    @include display-flex(row, flex-end, space-between);
    padding: 0.5em 0;
  }
  .menu-toggler{
    @include tiny-button($grey);
    align-self: center;
  }
  .buttons{
    a, button{
      @include tiny-button($light-blue);
    }
    @include display-flex(row, center, center, wrap);
    flex: 0 0 auto;
    white-space: nowrap;
  }
  /* Large screens */
  @media screen and (width >= $small-screen){
    .list-wrapper{
      min-width: 30em;
    }
    .buttons{
      a, button{
        margin: 0 0.5em;
      }
    }
  }

  /* Small screens */
  @media screen and (width < $small-screen){
    .list-label{
      margin-block-end: 0.5em;
      font-size: 1.2em;
    }
    .list-label-wrapper{
      text-align: center;
      @include display-flex(column, center, center);
      flex-direction: column;
    }
    .buttons{
      a, button{
        margin: 0.5em;
      }
    }
  }

  /* Very Small screens */
  @media screen and (width < $very-small-screen){
    .buttons{
      flex-direction: column;
      a, button{
        margin: 0.5em 0;
      }
    }
  }
</style>
