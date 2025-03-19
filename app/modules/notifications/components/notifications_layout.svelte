<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import Link from '#app/lib/components/link.svelte'
  import { getFriendsRequests } from '#app/modules/users/lib/relations'
  import Spinner from '#components/spinner.svelte'
  import { notifications } from '#notifications/lib/notifications'
  import { I18n } from '#user/lib/i18n'
  import FriendshipRequest from './friendship_request.svelte'
  import Notification from './notification.svelte'

  // TODO: mark notifications as read

  let friendshipRequests, flash
  const waitingForFriendsRequests = getFriendsRequests()
    .then(users => friendshipRequests = users)
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

  <!-- TODO -->
  <section class="groups-invitations">
    <h3>{I18n('pending groups invitations')}</h3>
    <div class="groups-invitations-list"></div>
  </section>

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
      icon="evenlope"
      text={I18n('email notifications settings')}
      classNames="show-notifications-settings button dark-grey"
    />
  </section>
</div>

<style lang="scss">
  @import '#general/scss/utils';

  .notifications-layout{
    @include central-column(50em);
    text-align: center;
    section{
      background-color: #eee;
      margin: 1em 0;
      padding: 1em;
      @include radius;
    }
    :global(.time){
      color: $grey;
    }
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
