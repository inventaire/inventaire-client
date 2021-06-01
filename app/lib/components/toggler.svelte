<script>
  import Flash from './flash.svelte'
  import { I18n } from 'modules/user/lib/i18n'
  export let name
  export let state
  export let togglePeriodicity
  let showFlash, hideFlash
  const description = name + '_notification'

  const updateSetting = () => {
    hideFlash()
    state = !state
    try {
      app.request('user:update', {
        attribute: `settings.notifications.${name}`,
        value: state,
        defaultPreviousValue: true
      })
    } catch {
      showFlash({
        priority: 'error',
        message: I18n('something went wrong, try again later')
      })
    }
    if (name === 'global' && state === false) {
      showFlash({
        priority: 'warning',
        message: I18n('global_email_toggle_warning')
      })
    }
    if (name === 'inventories_activity_summary') togglePeriodicity(state)
  }
</script>

<div class="wrapper" on:click={updateSetting}>
  <input type="checkbox" id={name} bind:checked={state}>
  <label for="emailNotifications">{I18n(description)}</label>
</div>
<Flash bind:show={showFlash} bind:hide={hideFlash}/>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  input{
    margin: 0;
    /*otherwise chrome do not display any checkbox*/
    appearance: auto;
  }
  .wrapper{
    display: flex;
    align-items: center;
  }
</style>
