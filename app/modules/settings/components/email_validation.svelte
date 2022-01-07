<script>
  import { icon } from 'lib/utils'
  import { I18n } from 'modules/user/lib/i18n'

  let validationEmailRequested = false

  async function emailConfirmationRequest () {
    validationEmailRequested = true
    try {
      await app.request('email:confirmation:request')
    } catch (err) {
      validationEmailRequested = false
      throw err
    }
  }
</script>

<div class="emailValidation">
  {#if validationEmailRequested}
    <div id="confirmationEmailSent" class="successMessageBox">
      {@html icon('check')}
      {@html I18n('new_confirmation_email')}
    </div>
  {:else}
    <div id="notValidEmail">
      {@html icon('warning')}
      {@html I18n('email_wasnt_verified')}
    </div>
    <button class="button dark-grey radius" on:click={emailConfirmationRequest}>
      {@html I18n('email_confirmation_error_button')}
    </button>
  {/if}
</div>

<style lang="scss">
  @import 'app/modules/general/scss/utils';

  .emailValidation{
    background-color: $soft-grey;
    @include radius;
    padding: 1em;
    margin: 1em 0;
  }

  #notValidEmail, #confirmationEmailSent{
    color: white;
    text-align: center;
  }

  button{
    @include radius;
    display: block;
    margin: 1em auto 0 auto;
  }

  #notValidEmail{
    width: 100%;
    background-color: $warning-color;
    padding: 0.5em;
    margin: 1em 0;
  }

  #confirmationEmailSent{
    @include radius;
    background-color: $success-color;
    padding: 0.5em;
  }
</style>
