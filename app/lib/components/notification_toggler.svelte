<script>
  import Flash from './flash.svelte'
  import { I18n } from '#user/lib/i18n'
  export let name
  export let value
  let flash
  const description = name + '_notification'

  const updateSetting = () => {
    flash = null
    try {
      app.request('user:update', {
        attribute: `settings.notifications.${name}`,
        value
      })
    } catch (err) {
      flash = err
    }
    setGlobalWarning()
  }

  function setGlobalWarning () {
    if (name === 'global' && value === false) {
      flash = {
        type: 'warning',
        message: I18n('global_email_toggle_warning')
      }
    }
  }

  setGlobalWarning()
</script>

<label>
  <input type="checkbox" name={name} id={name} bind:checked={value} on:change={updateSetting}>
  {I18n(description)}
</label>
<Flash bind:state={flash}/>

<style lang="scss">
  @import '#general/scss/utils';
  input{
    margin: 0;
  }
  label {
    display: block;
    font-size: 1rem;
    margin: 1em 0;
  }
</style>
