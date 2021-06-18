<script>
  import { I18n } from 'modules/user/lib/i18n'
  import app from 'app/app'
  import { wait } from 'lib/promises'
  import Profile from './profile.svelte'
  import Account from './account.svelte'
  import Notifications from './notifications.svelte'
  import Display from './display.svelte'
  import Data from './data.svelte'
  import { onMount } from 'svelte'
  export let section = 'profile'
  $: app.navigate(`/settings/${section}`)
  let settingEl, settingHeight
  // onMount runs after the component is first rendered
  // to ensure variable is bound after its creation
  onMount(() => settingHeight = settingEl.offsetTop)
  const isSmallScreen = window.screen.width < 470
  const goToSetting = sectionName => async () => {
    section = sectionName
    if (isSmallScreen) {
      await wait(5)
      window.scrollTo({
        top: settingHeight,
        behavior: 'smooth'
      })
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
        {I18n('display')}
      </button>
    </nav>
  </div>
  <div class="setting" bind:this={settingEl}>
    {#if section === 'profile'}
      <Profile user={app.user}/>
    {:else if section === 'account'}
      <Account user={app.user}/>
    {:else if section === 'notifications'}
      <Notifications/>
    {:else if section === 'display'}
      <Display/>
    {:else if section === 'data'}
      <Data user={app.user}/>
    {/if}
  </div>
</div>


<style lang="scss">
  @import 'app/modules/general/scss/utils';
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
    .active {
      border-left: solid 0.15em $yellow;
      padding-left: 0.85em;
      font-weight: bold;
    }
    button {
      padding: 1em;
      border-bottom: solid 1px #ccc;
      text-align: left;
      font-weight: normal;
    }
    :last-child {
      border-bottom: 0;
    }
  }
  .setting{
    width: 100%;
  }
  /*Large screens*/
  @media screen and (min-width: 470px) {
    .navigation{
      position: sticky;
      top: $topbar-height + 34px;
    }
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .wrapper{
      display: flex;
      flex-direction: column;
      margin-bottom: 0
    }
    .navigation{
      margin: 0;
    }
    .setting{
      margin-top: 2em;
      width: 100%;
      padding: 0
    }
  }
</style>
