<script>
  import Dropdown from '#components/dropdown.svelte'
  import Spinner from '#components/spinner.svelte'
  import { kickUserOutOfGroup, makeUserGroupAdmin, moveMembership } from '#groups/lib/groups'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/icons'
  import { loadInternalLink } from '#lib/utils'
  import { I18n } from '#user/lib/i18n'
  import UserLi from '#users/components/user_li.svelte'

  export let group, user

  const { _id: groupId, mainUserIsAdmin } = group
  const { _id: userId, pathname, isGroupAdmin } = user

  let makingAdmin, kickingOut, madeAdmin, kickedOut, flash, showDropdown

  async function makeAdmin () {
    try {
      makingAdmin = makeUserGroupAdmin({ groupId, userId })
      await makingAdmin
      madeAdmin = true
      showDropdown = false
    } catch (err) {
      flash = err
    }
  }
  async function kick () {
    try {
      kickingOut = kickUserOutOfGroup({ groupId, userId })
      await kickingOut
      kickedOut = true
      group = moveMembership(group, userId, 'members')
      showDropdown = false
    } catch (err) {
      flash = err
    }
  }
</script>

{#if !kickedOut}
  <UserLi {user}>
    {#if isGroupAdmin || madeAdmin}
      <span class="admin">{I18n('admin')}</span>
    {/if}
    {#if flash}
      <Flash bind:state={flash} />
    {:else}
      <Dropdown align="right" {showDropdown} dropdownWidthBaseInEm={10}>
        <div slot="button-inner">{@html icon('chevron-down')}</div>
        <ul slot="dropdown-content">
          <li>
            <a href={pathname} on:click={loadInternalLink}>
              {@html icon('user')}
              {I18n('see profile')}
            </a>
          </li>
          {#if mainUserIsAdmin}
            {#if !isGroupAdmin}
              <li>
                <button on:click={makeAdmin} disabled={makingAdmin || kickingOut}>
                  {#await makingAdmin}
                    <Spinner />
                  {:then}
                    {@html icon('key')}
                  {/await}
                  {I18n('make admin')}
                </button>
              </li>
              <li>
                <button on:click={kick} disabled={makingAdmin || kickingOut}>
                  {#await kickingOut}
                    <Spinner />
                  {:then}
                    {@html icon('ban')}
                  {/await}
                  {I18n('remove from group')}
                </button>
              </li>
            {/if}
          {/if}
        </ul>
      </Dropdown>
    {/if}
  </UserLi>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  button:not(:first-child){
    margin-inline-start: 0.2em;
  }
  [slot="button-inner"]{
    :global(.fa){
      @include text-hover($grey, $dark-grey);
    }
  }
  [slot="dropdown-content"]{
    white-space: nowrap;
    @include shy-border;
    @include display-flex(column, stretch);
    li{
      @include display-flex(row, stretch);
    }
    a, :global(button){
      @include display-flex(row, center, flex-start);
      flex: 1;
      @include bg-hover(white);
      padding: 0.5em;
    }
  }
</style>
