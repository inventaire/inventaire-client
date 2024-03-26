<script>
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'
  import { groupAction } from '#groups/lib/group_actions_alt'
  import { getGroup, serializeGroup } from '#groups/lib/groups'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/icons'
  import { I18n } from '#user/lib/i18n'

  export let group

  const { _id: groupId, pathname, open } = group

  let flash, mainUserIsMember, mainUserStatus, waitForAction

  $: ({ mainUserIsMember, mainUserStatus } = serializeGroup(group))

  const Action = actionName => async () => {
    try {
      if (app.request('require:loggedIn', pathname)) {
        waitForAction = _action(actionName)
        const updatedGroup = await waitForAction
        group = serializeGroup(updatedGroup)
      }
    } catch (err) {
      flash = err
    }
  }

  async function _action (actionName) {
    await groupAction({ action: actionName, groupId })
    return getGroup(groupId)
  }
</script>

<div class="actions">
  {#await waitForAction}
    <Spinner center={true} />
  {:then}
    {#if mainUserStatus === 'invited'}
      <button class="tiny-button success" on:click={Action('accept')}>
        {I18n('accept invitation')}
      </button>
      <button class="tiny-button grey" on:click={Action('decline')}>
        {I18n('decline')}
      </button>
    {/if}
    {#if mainUserStatus === 'requested'}
      <div>
        <p class="requested">
          {I18n('your request to join is waiting for approval')}
        </p>
        <button class="tiny-button grey" on:click={Action('cancel-request')}>
          {I18n('cancel request')}
        </button>
        <span class="check" />
      </div>
    {/if}
    {#if mainUserStatus === 'none'}
      <button class="tiny-button light-blue" on:click={Action('request')}>
        {#if open}
          {I18n('join group')}
        {:else}
          {I18n('request to join group')}
        {/if}
      </button>
      <span class="check" />
    {/if}
  {/await}
</div>
{#if !mainUserIsMember}
  <p class="restrictions">
    {@html icon('globe')} {I18n("as you are not a member of the group, you can only see members' public books")}
  </p>
{/if}

<Flash state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  .actions{
    @include display-flex(row);
    font-weight: normal;
    text-align: center;
    // Prevent jump when displaying the spinner
    min-height: 4em;
  }
  button{
    margin: 0 0.5em;
  }
  .requested{
    color: $dark-grey;
  }
  .restrictions{
    text-align: center;
    @include radius;
    @include tiny-button-padding;
    background-color: grey;
    color: white;
    margin: 0 0 0.5em;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    button{
      margin: 0;
    }
    .restrictions{
      margin: 0.5em;
    }
  }
</style>
