<script>
  import Flash from './flash.svelte'
  import { I18n } from 'modules/user/lib/i18n'
  export let name
  export let state
  export let togglePeriodicity, toggleNotifications
  let flash
  const description = name + '_notification'

  const updateSetting = () => {
    flash = null
    state = !state
    try {
      app.request('user:update', {
        attribute: `settings.notifications.${name}`,
        value: state
      })
    } catch (err) {
      flash = err
    }
    if (name === 'global') {
      toggleNotifications = !toggleNotifications
      if (state === false) {
        flash = {
          type: 'warning',
          message: I18n('global_email_toggle_warning')
        }
      }
    }
    if (name === 'inventories_activity_summary') togglePeriodicity(state)
  }
</script>

<div class="wrapper" on:click={updateSetting}>
  <input type="checkbox" id={name} bind:checked={state}>
  <label for="emailNotifications">{I18n(description)}</label>
</div>
<Flash bind:state={flash}/>

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
