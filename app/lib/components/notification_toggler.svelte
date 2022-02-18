<script>
  import Flash from './flash.svelte'
  import { I18n } from '#modules/user/lib/i18n'
  export let name
  export let value
  let flash
  const description = name + '_notification'

  const updateSetting = () => {
    flash = null
    value = !value
    try {
      app.request('user:update', {
        attribute: `settings.notifications.${name}`,
        value
      })
    } catch (err) {
      flash = err
    }
    if (name === 'global' && value === false) {
      flash = {
        type: 'warning',
        message: I18n('global_email_toggle_warning')
      }
    }
  }
</script>

<div class="wrapper" on:click={updateSetting}>
  <input type="checkbox" name={name} id={name} bind:checked={value}>
  <label for={name}>{I18n(description)}</label>
</div>
<Flash bind:state={flash}/>

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  input{
    margin: 0;
  }
  label {
    font-size: 1rem
  }
  .wrapper{
    display: flex;
    align-items: center;
  }
</style>
