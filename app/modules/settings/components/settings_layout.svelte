<script>
  import app from 'app/app'
  export let section = 'profile'
  $: app.navigate(`/settings/${section}`)
</script>

<div class="wrapper">
  <nav class="navigation">
    <a href='/settings/profile' class="{section === 'profile' ? 'active' : ''}" on:click={() => { section = 'profile' }}>
      Profile
    </a>
    <a href='/settings/account' class="{section === 'account' ? 'active' : ''}" on:click={() => { section = 'account' }}>
      Account
    </a>
    <a href='/settings/notifications' class="{section === 'notifications' ? 'active' : ''}" on:click={() => { section = 'notifications' }}>
      Notifications
    </a>
    <a href='/settings/data' class="{section === 'data' ? 'active' : ''}" on:click={() => { section = 'data' }}>
      Data
    </a>
  </nav>
  <div class="setting">
    {#if section === 'profile'}
      <div id='profile'>
        Profile
      </div>
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
