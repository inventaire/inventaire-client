<script>
  import { I18n } from 'modules/user/lib/i18n'
  import app from 'app/app'
  import { wait } from 'lib/promises'
  import Profile from './profile.svelte'
  import Account from './account.svelte'
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
      <button class="{section === 'profile' ? 'active' : ''}" on:click={goToSetting} on:click="{() => { section = 'profile' }}">
        {I18n('profile')}
      </button>
      <button class="{section === 'account' ? 'active' : ''}" on:click={goToSetting} on:click="{() => { section = 'account' }}">
        {I18n('account')}
      </button>
      <button class="{section === 'notifications' ? 'active' : ''}" on:click={goToSetting} on:click="{() => { section = 'notifications' }}">
        {I18n('notifications')}
      </button>
      <button class="{section === 'data' ? 'active' : ''}" on:click={goToSetting} on:click="{() => { section = 'data' }}">
        {I18n('data')}
      </button>
    </nav>
  </div>
  <div class="setting" bind:this={settingEl}>
    {#if section === 'profile'}
      <Profile user={app.user}/>
    {/if}
    {#if section === 'account'}
      <Account user={app.user}/>
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
    margin: 5em auto;
    max-width: 50em;
  }
  .navigation{
    display: flex;
    flex-direction: column;
    background-color: #fff;
    min-width: 10em;
    border-radius: 3px;
    margin-left: 2em;
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
    width: 70%;
  }
  /*Small screens*/
  @media screen and (max-width: 470px) {
    .wrapper{
      display: flex;
      flex-direction: column;
      margin: 5em 2em;
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
