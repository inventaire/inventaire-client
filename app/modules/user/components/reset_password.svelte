<script lang="ts">
  import app from '#app/app'
  import Spinner from '#components/spinner.svelte'
  import Flash from '#lib/components/flash.svelte'
  import PasswordInput from '#lib/components/password_input.svelte'
  import { loadInternalLink } from '#lib/utils'
  import { passwordUpdate } from '#user/lib/auth'
  import { i18n, I18n } from '#user/lib/i18n'
  import { testPassword } from '#user/lib/password_tests'
  import { user } from '#user/user_store'

  let password, flash, successFlash

  let updating = false
  let done = false
  async function updatePassword (e) {
    // Prevent the button click to trigger the <form> action
    e.preventDefault()
    try {
      updating = true
      testPassword(password)
      await passwordUpdate({ newPassword: password })
      done = true
      successFlash = { type: 'success', message: I18n('done'), role: 'alert' }
      app.execute('show:home')
    } catch (err) {
      flash = err
    } finally {
      updating = false
    }
  }
</script>

<div class="auth-menu">
  <div class="custom-cell">
    <h2 class="subheader">{i18n('reset password')}</h2>
    {#if done}
      <Flash state={successFlash} />
    {:else}
      <!-- Use a <form> to make the button be clicked on Enter and trigger to please password managers -->
      <form method="post">
        <input type="text" name="username" value={$user.username} />
        <div class="input-box">
          <PasswordInput
            bind:password
            title={I18n('password')}
            autocomplete="on"
          />
          <Flash state={flash} />
        </div>
        <button
          id="updatePassword"
          class="button success radius"
          on:click={updatePassword}
          disabled={updating}
        >
          {i18n('update password')}
          {#if updating}<Spinner />{/if}
        </button>
      </form>
      <div>
        <a href="/login/forgot-password" class="link" on:click={loadInternalLink}>
          {I18n('request_new_token')}
        </a>
      </div>
    {/if}
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#user/scss/auth_menu_commons';
  .auth-menu{
    @include auth-menu-commons;
  }
  .button{
    margin: 1em;
  }
  input[name="username"]{
    display: none;
  }
  .link{
    text-align: center;
    text-decoration: underline;
    text-decoration-color: $soft-grey;
  }
</style>
