<script>
  import app from '#app/app'
  import { scrollToElement } from '#lib/screen'
  import { I18n } from '#user/lib/i18n'
  import Account from './account.svelte'
  import Data from './data.svelte'
  import Display from './display.svelte'
  import Notifications from './notifications.svelte'
  import Profile from './profile.svelte'

  export let section = 'profile'

  $: app.navigate(`/settings/${section}`, {
    metadata: {
      title: `${I18n('settings')} - ${I18n(section)}`,
    },
  })

  let settingEl
  const isSmallScreen = window.screen.width < 470

  const goToSetting = sectionName => async () => {
    section = sectionName
    if (isSmallScreen) {
      scrollToElement(settingEl)
    }
  }
</script>

<div class="wrapper">
  <div class="subwrapper">
    <nav class="navigation">
      <button class:active={section === 'profile'} on:click={goToSetting('profile')}>
        {I18n('profile')}
      </button>
      <button class:active={section === 'account'} on:click={goToSetting('account')}>
        {I18n('account')}
      </button>
      <button class:active={section === 'notifications'} on:click={goToSetting('notifications')}>
        {I18n('notifications')}
      </button>
      <button class:active={section === 'data'} on:click={goToSetting('data')}>
        {I18n('data')}
      </button>
      <button class:active={section === 'display'} on:click={goToSetting('display')}>
        {I18n('display_name')}
      </button>
    </nav>
  </div>
  <div class="setting" bind:this={settingEl}>
    {#if section === 'profile'}
      <Profile />
    {:else if section === 'account'}
      <Account />
    {:else if section === 'notifications'}
      <Notifications />
    {:else if section === 'display'}
      <Display />
    {:else if section === 'data'}
      <Data user={app.user} />
    {/if}
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .wrapper{
    background-color: white;
    display: flex;
    flex-direction: row;
    margin: 3em auto;
    padding: 2em;
    max-width: 50em;
  }
  .navigation{
    display: flex;
    flex-direction: column;
    background-color: #fff;
    min-width: 10em;
    border-radius: 3px;
    border: solid 1px #ccc;
    .active{
      border-inline-start: solid 0.15em $yellow;
      padding-inline-start: 0.85em;
      font-weight: bold;
    }
    button{
      padding: 1em;
      border-block-end: solid 1px #ccc;
      text-align: start;
      font-weight: normal;
    }
    :last-child{
      border-block-end: 0;
    }
  }
  .setting{
    width: 100%;
  }
  /* Large screens */
  @media screen and (width >= 470px){
    .navigation{
      position: sticky;
      inset-block-start: $topbar-height + 34px;
    }
  }
  /* Small screens */
  @media screen and (width < 470px){
    .wrapper{
      display: flex;
      flex-direction: column;
      margin-block-end: 0;
    }
    .navigation{
      margin: 0;
    }
    .setting{
      margin-block-start: 2em;
      width: 100%;
      padding: 0;
    }
  }
</style>
