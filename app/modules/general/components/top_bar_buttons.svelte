<script lang="ts">
  import app from '#app/app'
  import Link from '#app/lib/components/link.svelte'
  import { screen } from '#app/lib/components/stores/screen'
  import { icon } from '#app/lib/icons'
  import { imgSrc } from '#app/lib/image_source'
  import { loadInternalLink } from '#app/lib/utils'
  import Dropdown from '#components/dropdown.svelte'
  import IconWithCounter from '#components/icon_with_counter.svelte'
  import { userGroupsInvitationsCount } from '#groups/lib/groups_data'
  import { unreadNotificationsCount } from '#notifications/lib/notifications'
  import { getUnreadTransactionsCountStore } from '#transactions/lib/get_transactions'
  import { I18n, i18n } from '#user/lib/i18n'
  import { mainUser } from '#user/lib/main_user'
  import { friendshipRequestsCount } from '#users/lib/relations'

  $: notificationsUpdates = $unreadNotificationsCount + $friendshipRequestsCount + $userGroupsInvitationsCount

  const unreadTransactionsCountStore = getUnreadTransactionsCountStore()
</script>

<div class="inner-top-bar-buttons">
  {#if !$screen.isSmallerThan('$small-screen')}
    <IconWithCounter
      label="exchanges"
      icon="exchange"
      href="/transactions"
      title="title_exchanges_layout"
      counter={$unreadTransactionsCountStore}
    />

    <IconWithCounter
      label="notifications"
      icon="bell"
      href="/notifications"
      title="notifications"
      counter={notificationsUpdates}
    />
  {/if}
  <div class="global-menu">
    <Dropdown
      clickOnContentShouldCloseDropdown={true}
      buttonTitle={i18n('global menu')}
      align="right"
      transitionDuration={0}
    >
      <div slot="button-inner">
        {#if $screen.isSmallerThan('$small-screen')}
          {@html icon('bars')}
        {:else}
          <img src={imgSrc($mainUser.picture, 32)} alt={i18n('profile pic')} />
          {@html icon('caret-down')}
        {/if}
      </div>
      <div slot="dropdown-content">
        <ul>
          <li>
            <a href={$mainUser.pathname} on:click={loadInternalLink}>
              <img src={imgSrc($mainUser.picture, 32)} alt="" />
              <span class="label">{$mainUser.username}</span>
            </a>
          </li>
          {#if $screen.isSmallerThan('$small-screen')}
            <li>
              <IconWithCounter
                label="exchanges"
                icon="exchange"
                href="/transactions"
                title="title_exchanges_layout"
                counter={$unreadTransactionsCountStore}
              />
            </li>
            <li>
              <IconWithCounter
                label="notifications"
                icon="bell"
                href="/notifications"
                title="notifications"
                counter={notificationsUpdates}
              />
            </li>
          {/if}
          <li>
            <Link
              icon="cog"
              url="/settings"
              text={I18n('settings')}
              stopClickPropagation={false}
            />
          </li>
          {#if app.user.hasDataadminAccess}
            <Link
              icon="server"
              url="/tasks"
              text={I18n('resolve tasks')}
              stopClickPropagation={false}
            />
          {/if}
          <li>
            <Link
              icon="info-circle"
              url="/welcome"
              text={I18n('info')}
              stopClickPropagation={false}
            />
          </li>
          <li>
            <Link
              icon="comments"
              url="/feedback"
              text={I18n('feedback')}
              stopClickPropagation={false}
            />
          </li>
          <li>
            <Link
              icon="sign-out"
              url="/logout"
              text={I18n('logout')}
              stopClickPropagation={false}
            />
          </li>
        </ul>
      </div>
    </Dropdown>
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";

  .inner-top-bar-buttons{
    align-self: stretch;
    @include display-flex(row, center, center);
  }

  .global-menu{
    align-self: stretch;
    @include display-flex(row, stretch, center);
    :global(a){
      @include display-flex(row, center, flex-start);
      flex: 1 0 auto;
      align-self: stretch;
      font-weight: bold;
      @include serif;
      @include bg-hover-lighten($topbar-bg-color);
      font-size: 1rem;
      padding: 0.8rem 1rem;
    }
    :global(a span:not(.counter)){
      color: white;
    }
    :global(a .fa){
      color: #aaa;
    }
    :global(.dropdown-button){
      @include bg-hover-lighten($topbar-bg-color);
      @include display-flex(row, center, center);
      color: white;
      /* Large screens */
      @media screen and (width >= $small-screen){
        align-self: stretch;
        padding: 0 0.5em;
      }
      /* Small screens */
      @media screen and (width < $small-screen){
        margin-inline-start: 0.2em;
        align-self: stretch;
      }
    }
    :global(.fa-caret-down){
      color: #ccc;
    }
    /* Small screens */
    @media screen and (width < $small-screen){
      :global(.fa-bars){
        font-size: 1.5rem;
      }
    }
  }
  ul{
    background-color: $topbar-bg-color;
    @include radius-bottom;
    font-weight: normal;
    @include sans-serif;
    :global(.fa){
      margin-inline-end: 0.5rem;
      @include display-flex(row, center, center);
    }
    img{
      height: 1.2em;
      width: 1.2em;
      margin-inline-start: 0.2em;
      margin-inline-end: 0.5em;
    }
    /* Very Small screens */
    @media screen and (width < $very-small-screen){
      // Going over 100vw to cover the whole screen
      min-width: 102vw;
    }

    /* Not Very Small screens */
    @media screen and (width >= $very-small-screen){
      min-width: 15em;
    }
  }
  img{
    @include radius;
    // Hard-coding the height and width is required so that color square svg can be properly sized
    height: 2em;
    width: 2em;
  }
</style>
