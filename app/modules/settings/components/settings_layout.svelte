<script>
  import { I18n } from 'modules/user/lib/i18n'
  import app from 'app/app'
  import { wait } from 'lib/promises'
  import Profile from './profile.svelte'
  import { onMount } from 'svelte'
  export let section = 'profile'
  $: app.navigate(`/settings/${section}`)
  let settingEl, settingHeight
  // onMount runs after the component is first rendered
  // to ensure variable is bound after its creation
  onMount(() => settingHeight = settingEl.offsetTop)
  const isSmallScreen = window.screen.width < 470
  const goToSetting = async () => {
    if (isSmallScreen) {
      await wait(5) //
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
      <a href='/settings/profile' class="{section === 'profile' ? 'active' : ''}" on:click={goToSetting} on:click={() => { section = 'profile' }}>
        {I18n('profile')}
      </a>
      <a href='/settings/account' class="{section === 'account' ? 'active' : ''}" on:click={goToSetting} on:click={() => { section = 'account' }}>
        {I18n('account')}
      </a>
      <a href='/settings/notifications' class="{section === 'notifications' ? 'active' : ''}" on:click={goToSetting} on:click={() => { section = 'notifications' }}>
        {I18n('notifications')}
      </a>
      <a href='/settings/data' class="{section === 'data' ? 'active' : ''}" on:click={goToSetting} on:click={() => { section = 'data' }}>
        {I18n('data')}
      </a>
    </nav>
  </div>
  <div class="setting" bind:this={settingEl}>
    {#if section === 'profile'}
      <Profile bind:user={app.user}/>
    {/if}
    {#if section === 'account'}
      Account
    {/if}
    {#if section === 'notifications'}
      Notifications
    {/if}
    {#if section === 'data'}
      Data
    {/if}
  </div>
</div>


<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .wrapper{
    display: flex;
    flex-direction: row;
    margin-top: 5em;
  }
  .navigation{
    display: flex;
    flex-direction: column;
    background-color: #fff;
    min-width: 10em;
    border-radius: 3px;
    margin-left: 2em;
    margin-right: 1.5em;
    border: solid 1px #ccc;
    .active {
      border-left: solid 0.15em $yellow;
      padding-left: 0.85em;
      font-weight: bold;
    }
    a {
      padding: 0.5em 1em;
      border-bottom: solid 1px #ccc;
      text-align: left;
      font-weight: normal;
    }
    :last-child {
      border-bottom: 0;
    }
  }
  .setting{
    width: 70%;
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .wrapper{
      display: flex;
      flex-direction: column;
      margin: 2em;
      margin-top: 5em;
    }
    .navigation{
      margin: 0;
    }
    .setting{
      margin-top: 2em;
      width: 100%;
    }
  }
</style>
