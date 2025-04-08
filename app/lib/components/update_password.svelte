<script lang="ts">
  import PasswordInput from '#app/lib/components/password_input.svelte'
  import { currentRoute } from '#app/lib/location'
  import log_ from '#app/lib/loggers'
  import { commands } from '#app/radio'
  import { passwordConfirmation, passwordUpdate } from '#user/lib/auth'
  import { I18n } from '#user/lib/i18n'
  import { mainUserStore } from '#user/lib/main_user'

  let flashCurrentPassword, flashNewPassword, form
  let currentPassword = '', newPassword = ''

  const updatePassword = async () => {
    if (!currentPassword || currentPassword.length < 8) {
      return flashCurrentPwdErr('wrong password')
    }
    if (!newPassword || newPassword.length < 8) {
      return flashNewPwdErr('password should be 8 characters minimum')
    }
    if (newPassword === currentPassword) {
      return flashNewPwdErr('current password and new password are the same, no need to update')
    }
    if (newPassword.length > 5000) {
      return flashNewPwdErr('password should be 5000 characters maximum')
    }
    flashNewPassword = { type: 'loading' }
    try {
      await passwordConfirmation(currentPassword)
    } catch (err) {
      if (err.statusCode === 401) return flashCurrentPwdErr('wrong password')
      else return flashCurrentPwdErr(err.message)
    }
    try {
      await passwordUpdate({ currentPassword, newPassword })
      flashNewPassword = {
        type: 'success',
        message: I18n('done'),
      }
      // Trigger password manager update
      form.submit()
    } catch (err) {
      // Logs the error and report it
      log_.error(err)
      flashCurrentPwdErr(err.message)
    }
  }

  const flashNewPwdErr = message => flashPasswordError({ input: 'new', message })

  const flashCurrentPwdErr = message => flashPasswordError({ input: 'current', message })

  const flashPasswordError = ({ input, message }) => {
    const args = {
      type: 'error',
      message: I18n(message),
    }
    if (input === 'new') {
      flashCurrentPassword = null
      flashNewPassword = args
    } else {
      flashCurrentPassword = args
      flashNewPassword = null
    }
  }
</script>

<form>
  <!-- Add the username in a form to give a hint to the browser of which user credentials should be used to autocomplete -->
  <input
    type="text"
    name="username"
    value={$mainUserStore.username}
    class="hidden"
  />
  <PasswordInput
    bind:password={currentPassword}
    bind:flash={flashCurrentPassword}
    title={I18n('current password')}
    autocomplete="on"
  />
</form>
<div class="forgotPassword">
  <a href="/login/forgot-password" class="link" on:click={() => commands.execute('show:forgot:password')}>{I18n('forgot your password?')}</a>
</div>

<form method="post" action="/api/submit?redirect={currentRoute()}" bind:this={form}>
  <input
    type="text"
    name="username"
    value={$mainUserStore.username}
    class="hidden"
  />
  <PasswordInput
    bind:password={newPassword}
    bind:flash={flashNewPassword}
    title={I18n('new password')}
    autocomplete="on"
  />
</form>

<button class="light-blue-button" on:click={updatePassword}>{I18n('change password')}</button>

<style lang="scss">
  @use "#general/scss/utils";

  .forgotPassword .link{
    font-size: 0.9rem;
    color: #777;
  }
  .hidden{
    display: none;
  }
</style>
