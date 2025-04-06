<script lang="ts">
  import Flash, { type FlashState } from '#app/lib/components/flash.svelte'
  import { newError } from '#app/lib/error'
  import { icon } from '#app/lib/icons'
  import { buildPath } from '#app/lib/location'
  import preq from '#app/lib/preq'
  import { loadInternalLink } from '#app/lib/utils'
  import { I18n, i18n } from '#user/lib/i18n'

  export let data: string
  export let sig: string

  let flash: FlashState
  let buttonText, buttonAction, description
  try {
    const actionData = JSON.parse(atob(data as string))
    const { endpoint, action, attribute, value } = actionData

    if (endpoint === 'user' && action === 'update' && attribute.startsWith('settings.notifications.') && value === false) {
      const notificationKey = attribute.split('.')[2]
      description = I18n(notificationKey + '_notification')
      buttonText = i18n('Unsubscribe')
      buttonAction = async () => {
        await preq.post(buildPath('/api/auth', { action: 'signed-url', data, sig }))
      }
    }
    else {
      flash = newError('unsupported case', 400, actionData)
    }
  }
  catch (err) {
    flash = err
  }

  async function runAction() {
    try {
      await buttonAction()
      flash = { type: 'success', message: i18n('Successfully unsubscribed'), canBeClosed: false }
    }
    catch (err) {
      flash = err
    }
  }
</script>

<div class="auth-menu">
  <div class="custom-cell">
    {#if flash}
      <Flash state={flash} />
    {:else}
      <p>{description}</p>
      <div class="buttons">
        <button on:click={runAction} class="button">{buttonText}</button>
      </div>
    {/if}
  </div>
  <div class="custom-cell">
    <p>{I18n('notifications_description')}</p>
    <a href="/settings/notifications" on:click={loadInternalLink} class="button grey">
      {@html icon('envelope')}
      {i18n('Notifications settings')}
    </a>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#user/scss/auth_menu_commons';

  .auth-menu{
    @include central-column(40em);
  }
  .button{
    margin: 0.5em;
  }
  .custom-cell{
    margin: 1em 0;
  }
</style>
