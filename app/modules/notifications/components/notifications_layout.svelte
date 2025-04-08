<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import Link from '#app/lib/components/link.svelte'
  import Spinner from '#components/spinner.svelte'
  import GroupLi from '#groups/components/group_li.svelte'
  import { getGroupInvitations } from '#groups/lib/groups_data'
  import { markNotificationsAsRead, notifications } from '#notifications/lib/notifications'
  import { I18n } from '#user/lib/i18n'
  import { getFriendshipRequests } from '#users/lib/relations'
  import FriendshipRequest from './friendship_request.svelte'
  import Notification from './notification.svelte'

  let friendshipRequests, groupsInvications, flash

  markNotificationsAsRead(notifications)
    .catch(err => flash = err)

  const waitingForFriendsRequests = getFriendshipRequests()
    .then(users => friendshipRequests = users)
    .catch(err => flash = err)

  const waitingForGroupsInvitations = getGroupInvitations()
    .then(groups => groupsInvications = groups)
    .catch(err => flash = err)
</script>

<div class="notifications-layout">
  <Flash state={flash} />

  {#await waitingForFriendsRequests}
    <Spinner center={true} />
  {:then}
    {#if friendshipRequests.length > 0}
      <section class="friends-requests">
        <h3>{I18n('pending friends requests')}</h3>
        <ul class="friends-requests-list">
          {#each friendshipRequests as user (user._id)}
            <FriendshipRequest {user} />
          {/each}
        </ul>
      </section>
    {/if}
  {/await}

  {#await waitingForGroupsInvitations}
    <Spinner center={true} />
  {:then}
    {#if groupsInvications.length > 0}
      <section class="groups-invitations">
        <h3>{I18n('pending groups invitations')}</h3>
        <ul class="groups-invitations-list">
          {#each groupsInvications as group (group._id)}
            <GroupLi {group} />
          {/each}
        </ul>
      </section>
    {/if}
  {/await}

  <section class="notifications">
    <h3>{I18n('notifications')}</h3>
    <ul class="notifications-list">
      {#each notifications as notification (notification._id)}
        <li>
          <Notification {notification} />
        </li>
      {:else}
        <li class="empty">{I18n('no notification')}</li>
      {/each}
    </ul>

    <Link
      url="/settings/notifications"
      icon="envelope"
      text={I18n('email notifications settings')}
      classNames="show-notifications-settings button dark-grey"
    />
  </section>
</div>

<style lang="scss">
  @use '#general/scss/utils';

  .notifications-layout{
    @include central-column(50em);
    text-align: center;
    :global(.time){
      color: $grey;
    }
  }
  section{
    background-color: #eee;
    margin: 1em 0;
    padding: 1em;
    @include radius;
  }
  h3{
    font-size: 1.2rem;
    @include sans-serif;
  }
  .notifications{
    ul{
      max-height: 20em;
      overflow: auto;
    }
    :global(.show-notifications-settings){
      margin-block-start: 1em;
    }
    :global(.show-notifications-settings .fa){
      margin-inline-end: 0.5em;
    }
  }
</style>
