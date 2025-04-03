<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { timeFromNow } from '#app/lib/time'
  import { loadInternalLink } from '#app/lib/utils'
  import { getGroup } from '#groups/lib/groups'
  import type { Notification } from '#server/types/notification'
  import { i18n } from '#user/lib/i18n'
  import { getUserById } from '#users/users_data'
  import { getNotificationText } from '../lib/notifications'

  export let notification: Notification

  const { type, time, data, status } = notification
  let user, group, flash, text, textContext
  const unread = status === 'unread'

  let waitingForUser, waitingForGroup
  if (data.user) {
    waitingForUser = getUserById(data.user)
      .then(res => user = res)
      .catch(err => flash = err)
  }

  if ('group' in data) {
    waitingForGroup = getGroup(data.group)
      .then(res => group = res)
      .catch(err => flash = err)
  }

  const waitingForData = Promise.all([
    waitingForUser,
    waitingForGroup,
  ])
    .then(() => {
      if (group) {
        // @ts-expect-error
        text = getNotificationText(type, data.attribute, data.newValue)
        textContext = {
          groupName: group.name,
          username: user.username,
          // @ts-expect-error
          previousValue: data.previousValue,
          // @ts-expect-error
          newValue: data.newValue,
        }
      }
    })
    .catch(err => flash = err)
</script>

{#await waitingForData then}
  <li class="notification" class:unread>
    {#if type === 'friendAcceptedRequest'}
      <a class="notification-link" href={user.pathname} on:click={loadInternalLink}>
        <img src={imgSrc(user.picture, 48)} alt={user.username} />
        <div class="info">
          <span>{@html i18n('friend_accepted_request', { username: user.username })}</span><br />
          <span class="time">{timeFromNow(time)}</span>
        </div>
        <div class="unread-flag">{@html icon('circle')}</div>
      </a>
    {:else if type === 'groupUpdate' || type === 'userMadeAdmin'}
      <a class="notification-link {type}" href={group.pathname}>
        <img src={imgSrc(group.picture, 48)} alt={group.name} />
        <div class="info">
          <span>{@html i18n(text, textContext)}</span><br />
          <span class="time">{timeFromNow(time)}</span>
        </div>
        {#if unread}
          <div class="unread-flag">{@html icon('circle')}</div>
        {/if}
      </a>
    {/if}
  </li>
{/await}

<Flash state={flash} />

<style lang="scss">
  @import '#general/scss/utils';
  .notification{
    text-align: start;
    margin: 0.1em;
    padding: 0.5em;
    @include shy-border;
    @include radius;
    &.unread{
      background-color: $unread-color;
    }
    &:not(.unread){
      @include bg-hover(white);
      .unread-flag{
        display: none;
      }
    }
    img{
      max-height: 3em;
      max-width: 3em;
      @include radius;
    }
  }
  .notification-link{
    @include display-flex(row, flex-start, flex-start);
    width: 100%;
    .info{
      flex: 1 1 auto;
      padding: 0 0.5em;
    }
  }
  .unread-flag{
    @include display-flex(row, center, center);
    margin-inline-start: 0.3em;
    font-size: 0.8em;
    opacity: 0.8;
    align-self: center;
    flex: 0 0 auto;
    padding: 0.2em;
    :global(.fa){
      color: $light-blue;
    }
  }
</style>
