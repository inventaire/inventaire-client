<script>
  import Spinner from '#components/spinner.svelte'
  import { acceptRequestToJoinGroup, inviteUserToJoinGroup, moveMembership, refuseRequestToJoinGroup } from '#groups/lib/groups'
  import Flash from '#lib/components/flash.svelte'
  import { icon } from '#lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'
  import UserLi from '#users/components/user_li.svelte'

  export let group, user

  const { _id: groupId } = group
  const { _id: userId } = user

  let accepting, refusing, inviting, accepted, refused, flash

  let { isGroupAdmin, isGroupMember, requestedToJoinGroup, wasInvitedToJoinGroup, declinedToJoinGroup } = user

  async function accept () {
    try {
      accepting = acceptRequestToJoinGroup({ groupId, requesterId: userId })
      await accepting
      accepted = true
      group = moveMembership(group, userId, 'requested', 'members')
    } catch (err) {
      flash = err
    }
  }
  async function refuse () {
    try {
      refusing = refuseRequestToJoinGroup({ groupId, requesterId: userId })
      await refusing
      refused = true
      group = moveMembership(group, userId, 'requested')
    } catch (err) {
      flash = err
    }
  }

  async function invite () {
    try {
      inviting = inviteUserToJoinGroup({ groupId, invitedUserId: userId })
      await inviting
      wasInvitedToJoinGroup = true
      group = moveMembership(group, userId, null, 'invited')
    } catch (err) {
      flash = err
    }
  }
</script>

<UserLi {user}>
  {#if flash}
    <Flash bind:state={flash} />
  {:else if isGroupAdmin}
    <span class="done">{i18n('admin')}</span>
  {:else if isGroupMember}
    <span class="done">{I18n('member')}</span>
  {:else if accepted}
    <span class="done">{i18n('request accepted')}</span>
  {:else if refused}
    <span class="done">{i18n('request rejected')}</span>
  {:else if declinedToJoinGroup}
    <span class="done">{i18n('declined invitation')}</span>
  {:else if requestedToJoinGroup}
    <button
      class="tiny-button success"
      title={I18n("validate user's request to join the group")}
      on:click={accept}
      disabled={accepting || refusing}
    >
      {#await accepting}
        <Spinner light={true} />
      {:then}
        {@html icon('plus')}
      {/await}
      {I18n('accept')}
    </button>
    <button
      class="tiny-button"
      title={I18n("discard user's request to join the group")}
      on:click={refuse}
      disabled={accepting || refusing}
    >
      {#await refusing}
        <Spinner light={true} />
      {:then}
        {@html icon('ban')}
      {/await}
      {I18n('refuse')}
    </button>
  {:else if wasInvitedToJoinGroup}
    <span class="done">{i18n('invited')}</span>
    <!-- TOOD: add cancel invitation button once cancel-invitation action is implemented in the server -->
  {:else}
    <button
      class="tiny-button success"
      title={I18n('invite user to join the group')}
      on:click={invite}
      disabled={inviting}
    >
      {#await inviting}
        <Spinner light={true} />
      {:then}
        {@html icon('plus')}
      {/await}
      {I18n('invite')}
    </button>
  {/if}
</UserLi>

<style lang="scss">
  @import "#general/scss/utils";
  button:not(:first-child){
    margin-inline-start: 0.2em;
  }
  .done{
    opacity: 0.8;
    padding: 0 1em;
  }
</style>
