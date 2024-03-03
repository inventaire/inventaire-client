<script>
  import { I18n } from '#user/lib/i18n'
  import { loadInternalLink } from '#lib/utils'
  import { icon } from '#lib/icons'
  import { user } from '#user/user_store'
  import { emailConfirmationRequest } from '#user/lib/auth'
  import Flash from '#lib/components/flash.svelte'
  import Modal from '#components/modal.svelte'
  import Spinner from '#components/spinner.svelte'

  export let validEmail

  let flash, requestingEmail
  let showModal = true

  async function requestEmailConfirmation () {
    try {
      requestingEmail = emailConfirmationRequest()
      await requestingEmail
      flash = { type: 'success', message: I18n('done'), role: 'alert' }
      showModal = false
    } catch (err) {
      flash = err
    }
  }

  function onLinkClick (e) {
    loadInternalLink(e)
    showModal = false
  }
</script>

{#if showModal}
  <Modal on:closeModal={() => showModal = false}>
    <div class="valid-email-confirmation">
      {#if validEmail}
        <div class="valid">
          <p>
            {@html icon('check')}
            {I18n('email_confirmation_success')}
          </p>
          {#if $user._id}
            <a href={$user.pathname} class="button dark-grey radius" on:click={onLinkClick}>
              {I18n('back to your inventory')}
            </a>
          {:else}
            <a href="/login" class="button dark-grey radius" on:click={onLinkClick}>
              {I18n('login to your inventory')}
            </a>
          {/if}
        </div>
      {:else}
        <div class="invalid">
          <p>
            {@html icon('bolt')}
            {I18n('email_confirmation_error')}
          </p>
          {#if $user._id}
            <button class="button dark-grey radius" on:click={requestEmailConfirmation} disabled={requestingEmail != null}>
              {I18n('email_confirmation_error_button')}
              {#await requestingEmail}
                <Spinner />
              {/await}
            </button>
          {:else}
            <p class="offline">
              {I18n('email_confirmation_offline_error')}
            </p>
            <a href="/login?redirect=settings/profile" class="button dark-grey radius" on:click={onLinkClick}>
              {I18n('login')}
            </a>
          {/if}
        </div>
      {/if}
      <Flash state={flash} />
    </div>
  </Modal>
{/if}

<style lang="scss">
  @import '#general/scss/utils';

  .valid-email-confirmation{
    text-align: center;
    @include sans-serif;
    color: white;
  }
  p{
    margin-block-end: 1em;
    @include radius;
    @include display-flex(row, center, center);
  }
  .button{
    font-weight: bold !important;
  }
  .valid{
    p{
      background-color: $success-color;
      padding: 0.5em;
    }
    color: white;
  }
  .invalid{
    p:not(.offline){
      background-color: $warning-color;
      padding: 0.5em;
    }
  }
  p.offline{
    color: $dark-grey;
  }
</style>
