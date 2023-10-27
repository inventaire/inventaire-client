<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { user } from '#user/user_store'
  import Flash from '#lib/components/flash.svelte'
  import { testEmail, verifyKnownEmail } from '#user/lib/email_tests'
  import Spinner from '#components/spinner.svelte'
  import { passwordResetRequest } from '#user/lib/auth'

  export let resetPasswordFail = false

  let email = $user.email
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
      await verifyKnownEmail(email)
      await passwordResetRequest(email)
      done = true
      flash = {
        type: 'success',
        message: I18n('confirmation_password_reset_email_sent'),
        role: 'alert',
        canBeClosed: false,
      }
    } catch (err) {
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
    {#if !done}
      <div class="inputBox">
        <input
          type="email"
          placeholder="alice@example.org"
          bind:value={email}
          on:keydown={resetFlash}
          required
        />
      </div>
    {/if}
    <Flash state={flash} />
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
  .inputBox{
    margin: 1em;
  }
  .button{
    margin-block-start: 0.5em;
  }
</style>