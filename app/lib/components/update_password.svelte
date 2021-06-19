<script>
  import app from 'app/app'
  import log_ from 'lib/loggers'
  import PasswordInput from 'lib/components/password_input.svelte'
  import { i18n, I18n } from 'modules/user/lib/i18n'

  let flashCurrentPassword, flashNewPassword
  let currentPassword = '', newPassword = ''

  const updatePassword = async () => {
    if (!currentPassword || currentPassword.length < 8) {
      return flashCurrentPwdErr('wrong password')
    }
    if (!newPassword || newPassword.length < 8) {
      return flashNewPwdErr('password should be 8 characters minimum')
    }
    if (newPassword === currentPassword) {
      return flashNewPwdErr("that's the same password")
    }
    if (newPassword.length > 5000) {
      return flashNewPwdErr('password should be 5000 characters maximum')
    }
    try {
      await app.request('password:confirmation', currentPassword)
    } catch (err) {
      if (err.statusCode === 401) return flashCurrentPwdErr('wrong password')
    }
    try {
      await app.request('password:update', currentPassword, newPassword)
      flashNewPassword = {
        type: 'success',
        message: I18n('done')
      }
    } catch (err) {
      // Logs the error and report it
      log_.error(err)
      return flashCurrentPwdErr('something went wrong, try again later')
    }
  }

  const flashNewPwdErr = message => flashPasswordError({ input: 'new', message })

  const flashCurrentPwdErr = message => flashPasswordError({ input: 'current', message })

  const flashPasswordError = ({ input, message }) => {
    const args = {
      type: 'error',
      message: I18n(message)
    }
    if (input === 'new') {
      return flashNewPassword = args
    } else {
      return flashCurrentPassword = args
    }
  }
</script>
<h3>{i18n('current password')}</h3>
<PasswordInput bind:password={currentPassword} bind:flash={flashCurrentPassword} name="currentPassword"/>
<div class="forgotPassword">
  <a href="/login/forgot-password" class="link" on:click="{() => app.execute('show:forgot:password')}">{i18n('forgot your password?')}</a>
</div>
<h3>{i18n('new password')}</h3>
<PasswordInput bind:password={newPassword} bind:flash={flashNewPassword} name="newPassword"/>
<button class="light-blue-button" on:click="{updatePassword}">{I18n('change password')}</button>
<style>
  .forgotPassword .link{
    font-size: 90%;
    color: #777;
  }
  h3{
    margin-top: 1em;
    margin-bottom: 0.2em;
    font: sans-serif;
    font-size: 110%;
    font-weight: 600;
  }
</style>
