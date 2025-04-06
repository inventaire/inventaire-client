<script lang="ts">
  import Flash from '#app/lib/components/flash.svelte'
  import { I18n } from '#user/lib/i18n'
  import { updateUser } from '#user/lib/main_user'

  export let name: string
  export let value: boolean
  let flash
  const description = name + '_notification'

  async function updateSetting () {
    flash = null
    try {
      await updateUser(`settings.notifications.${name}`, value)
    } catch (err) {
      flash = err
    }
    setGlobalWarning()
  }

  function setGlobalWarning () {
    if (name === 'global' && value === false) {
      flash = {
        type: 'warning',
        message: I18n('global_email_toggle_warning'),
      }
    }
  }

  setGlobalWarning()
</script>

<label>
  <input
    type="checkbox"
    {name}
    id={name}
    bind:checked={value}
    on:change={updateSetting}
  />
  {I18n(description)}
</label>
<Flash bind:state={flash} />

<style lang="scss">
  @import "#general/scss/utils";
  input{
    margin: 0;
  }
  label{
    display: block;
    font-size: 1rem;
    margin: 1em 0;
  }
</style>
