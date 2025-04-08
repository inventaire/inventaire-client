<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { reqres } from '#app/radio'
  import Spinner from '#components/spinner.svelte'
  import { groupAction } from '#groups/lib/group_actions_alt'
  import { serializeGroup, type SerializedGroup } from '#groups/lib/groups'
  import { I18n } from '#user/lib/i18n'

  export let group: SerializedGroup

  const { _id: groupId, pathname, open } = group

  let flash, mainUserIsMember, mainUserStatus, waitForAction

  $: ({ mainUserIsMember, mainUserStatus } = serializeGroup(group))

  const processing: Record<string, boolean> = {}
  async function action (actionName: string) {
    try {
      if (reqres.request('require:loggedIn', pathname)) {
        processing[actionName] = true
        waitForAction = groupAction({ action: actionName, groupId })
        const updatedGroup = await waitForAction
        group = serializeGroup(updatedGroup)
      }
    } catch (err) {
      flash = err
    } finally {
      processing[actionName] = false
    }
  }
</script>

<div class="actions">
  {#await waitForAction}
    <Spinner center={true} />
  {:then}
    {#if mainUserStatus === 'invited'}
      <button class="tiny-button success" on:click={() => action('accept')} disabled={processing.accept || processing.decline}>
        {I18n('accept invitation')}
        {#if processing.accept}<Spinner />{/if}
      </button>
      <button class="tiny-button grey" on:click={() => action('decline')} disabled={processing.accept || processing.decline}>
        {I18n('decline')}
        {#if processing.decline}<Spinner />{/if}
      </button>
    {:else if mainUserStatus === 'requested'}
      <div>
        <p class="requested">
          {I18n('your request to join is waiting for approval')}
        </p>
        <button class="tiny-button grey" on:click={() => action('cancel-request')} disabled={processing['cancel-request']}>
          {I18n('cancel request')}
          {#if processing['cancel-request']}<Spinner />{/if}
        </button>
      </div>
    {:else if mainUserStatus === 'none'}
      <button class="tiny-button light-blue" on:click={() => action('request')} disabled={processing.request}>
        {#if open}
          {I18n('join group')}
        {:else}
          {I18n('request to join group')}
        {/if}
        {#if processing.request}<Spinner />{/if}
      </button>
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
  @use "#general/scss/utils";
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
  @media screen and (width < $small-screen){
    button{
      margin: 0;
    }
    .restrictions{
      margin: 0.5em;
    }
  }
</style>
