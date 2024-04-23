<script lang="ts">
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import Flash from '#app/lib/components/flash.svelte'
  import PasswordInput from '#app/lib/components/password_input.svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import Spinner from '#components/spinner.svelte'
  import { requestSignup } from '#user/lib/auth'
  import { verifyEmail } from '#user/lib/email_tests'
  import { i18n, I18n } from '#user/lib/i18n'
  import { testPassword } from '#user/lib/password_tests'
  import { verifyUsername } from '#user/lib/username_tests'

  export let redirect = null

  let username, email, password
  let usernameFlash, emailFlash, passwordFlash, signupFlash
  let usernameInputNode, emailInputNode

  async function earlyVerifyUsername () {
    if (!username) return
    try {
      username = username.trim()
      if (username) await verifyUsername(username)
    } catch (err) {
      usernameFlash = err
    }
  }

  async function earlyVerifyEmail () {
    try {
      if (email) await verifyEmail(email)
    } catch (err) {
      emailFlash = err
    }
  }

  let signingUp = false
  async function signup (e) {
    // Prevent the button click to trigger the <form> action
    e.preventDefault()
    try {
      signingUp = true
      // Taking values directly from input to avoid missing changes triggered
      // by password managers/addons/user scripts rather than user input
      username = usernameInputNode.value.trim()
      email = emailInputNode.value.trim()
      await verifyUsername(username)
      await verifyEmail(email)
      testPassword(password)
      await requestSignup({ username, email, password })
      location.href = redirect || '/'
    } catch (err) {
      signupFlash = err
    } finally {
      signingUp = false
    }
  }
</script>

<div class="auth-menu">
  <!-- Use a <form> to make the button be clicked on Enter and trigger to please password managers -->
  <form
    class="custom-cell"
    method="post"
    autocomplete="on"
    autocorrect="off"
    autocapitalize="off"
  >
    <h2 class="subheader">{i18n('Create account')}</h2>

    <label for="username">{i18n('username')}</label>
    <div class="input-box">
      <input
        type="text"
        name="username"
        id="username"
        required
        bind:value={username}
        bind:this={usernameInputNode}
        on:blur={earlyVerifyUsername}
        on:keydown={() => {
          usernameFlash = null
          signupFlash = null
        }}
        use:autofocus
      />
      <Flash state={usernameFlash} />
    </div>

    <label for="email">{i18n('email')}</label>
    <div class="input-box">
      <input
        type="text"
        name="email"
        id="email"
        required
        bind:value={email}
        bind:this={emailInputNode}
        on:blur={earlyVerifyEmail}
        on:keydown={() => {
          emailFlash = null
          signupFlash = null
        }}
      />
      <Flash state={emailFlash} />
    </div>

    <div class="input-box">
      <PasswordInput
        bind:password
        bind:flash={passwordFlash}
        title={I18n('password')}
        autocomplete="on"
      />
    </div>

    <Flash state={signupFlash} />

    <button
      id="signup"
      class="button"
      on:click={signup}
      disabled={usernameFlash || emailFlash || passwordFlash || signupFlash || signingUp}
    >
      {i18n('signup_verb')}
      {#if signingUp}<Spinner />{/if}
    </button>

    <hr />

    <div class="other-options">
      <p>
        {i18n('Already have an account?')}
        <a class="classic-link" href="/login" on:click={loadInternalLink}>{I18n('login_verb')}</a>
      </p>
    </div>
  </form>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#user/scss/auth_menu_commons';
  .auth-menu{
    @include auth-menu-commons;
    @include input-box;
    @include auth-menu-with-other-options;
  }
  h2{
    margin-block-end: 0.8em;
  }
  button#signup{
    // separate the display password and signup buttons
    margin-block-start: 1.6em;
  }
</style>
