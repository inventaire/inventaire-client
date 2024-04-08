<script lang="ts">
  import Spinner from '#components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { passwordResetRequest } from '#user/lib/auth'
  import { testEmail } from '#user/lib/email_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import { user } from '#user/user_store'

  export let resetPasswordFail = false
  export let email = $user.email

  let flash, resetPasswordFailFlash
  let sending = false
  let done = false

  if (resetPasswordFail) {
    resetPasswordFailFlash = new Error(i18n('Failed to reset password. You can retry below.'))
  }

  async function sendEmail (e) {
    // Prevent the button click to trigger the <form> action
    e.preventDefault()
    resetPasswordFailFlash = null
    try {
      sending = true
      testEmail(email)
      await passwordResetRequest(email)
      done = true
      flash = {
        type: 'success',
        message: I18n('confirmation_password_reset_email_sent'),
        role: 'alert',
        canBeClosed: false,
      }
    } catch (err) {
      if (err.message === 'email not found') {
        err.message = I18n('this email is unknown')
      }
      flash = err
    } finally {
      sending = false
    }
  }

  function resetFlash () {
    flash = null
    resetPasswordFailFlash = null
  }
</script>

<div class="auth-menu">
  <!-- Use a <form> to make the button be clicked on Enter -->
  <form class="custom-cell">
    <div class="reset-password-failed">
      <Flash state={resetPasswordFailFlash} />
    </div>

    <h2 class="subheader">{i18n('forgot password?')}</h2>
    <p class="note">{i18n('Enter the email address you used to sign up to get a link to reset your password')}</p>
    <div class="input-box">
      {#if !done}
        <input
          type="email"
          placeholder={i18n('email')}
          bind:value={email}
          on:keydown={resetFlash}
          required
        />
      {/if}
      <Flash state={flash} />
    </div>
    {#if !done}
      <button on:click={sendEmail} disabled={sending} class="button radius">
        {I18n('send email')}
        {#if sending}<Spinner />{/if}
      </button>
    {/if}
  </form>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#user/scss/auth_menu_commons';
  .auth-menu{
    @include auth-menu-commons;
    @include input-box;
  }
  .reset-password-failed{
    margin-block-end: 1em;
    :global(.flash){
      padding: 0.2em;
    }
  }
  .input-box{
    margin: 1em;
  }
  .button{
    margin-block-start: 0.5em;
  }
</style>
