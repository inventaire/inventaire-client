<script>
  import Spinner from '#components/spinner.svelte'
  import { isEmail } from '#lib/boolean_tests'
  import { autofocus } from '#lib/components/actions/autofocus'
  import Flash from '#lib/components/flash.svelte'
  import PasswordInput from '#lib/components/password_input.svelte'
  import { onChange } from '#lib/svelte/svelte'
  import { fixedEncodeURIComponent, loadInternalLink } from '#lib/utils'
  import { requestLogin } from '#user/lib/auth'
  import { i18n, I18n } from '#user/lib/i18n'
  import { testPassword } from '#user/lib/password_tests'
  import { passUsernameTests } from '#user/lib/username_tests'

  export let redirect = null

  let username, password
  let usernameFlash, loginFlash
  let usernameInputNode

  function earlyVerifyUsername () {
    try {
      if (username && !isEmail(username)) passUsernameTests(username)
    } catch (err) {
      usernameFlash = err
    }
  }

  let loggingIn = false
  async function login (e) {
    // Prevent the button click to trigger the <form> action
    e.preventDefault()
    try {
      loggingIn = true
      // Taking value directly from input to avoid missing changes triggered
      // by password managers/addons/user scripts rather than user input
      username = usernameInputNode.value.trim()
      if (!isEmail(username)) passUsernameTests(username)
      testPassword(password)
      await requestLogin({ username, password })
      location.href = redirect || '/'
    } catch (err) {
      loginFlash = formatLoginError(err)
    } finally {
      loggingIn = false
    }
  }

  function formatLoginError (err) {
    if (err.statusCode === 401) {
      if (isEmail(username)) {
        err.message = 'email or password is incorrect'
      } else {
        err.message = 'username or password is incorrect'
      }
    }
    return err
  }

  let forgotPasswordHref

  function setEmailQuerystring () {
    forgotPasswordHref = '/login/forgot-password'
    if (isEmail(username)) {
      forgotPasswordHref += `?email=${fixedEncodeURIComponent(username)}`
    }
  }

  $: onChange(username, setEmailQuerystring)
</script>
<div class="auth-menu">
  <div class="custom-cell">
    <h2 class="subheader">{i18n('login')}</h2>
    <!-- Use a <form> to make the button be clicked on Enter and trigger to please password managers -->
    <form
      method="post"
      autocomplete="on"
      autocorrect="off"
      autocapitalize="off"
    >
      <label for="username">
        <span class="main">{I18n('username')}</span>
        <span class="complement">({i18n('or email address')})</span>
      </label>
      <div class="input-box">
        <input
          type="text"
          name="username"
          id="username"
          required
          bind:value={username}
          bind:this={usernameInputNode}
          on:blur={earlyVerifyUsername}
          on:keydown={() => usernameFlash = null}
          use:autofocus
        />
        <Flash state={usernameFlash} />
      </div>

      <div class="input-box">
        <PasswordInput
          bind:password
          title={I18n('password')}
          autocomplete="on"
        />
      </div>

      <Flash state={loginFlash} />

      <button
        id="login"
        class="button light-blue"
        on:click={login}
        disabled={usernameFlash || loginFlash || loggingIn}
      >
        {i18n('login_verb')}
        {#if loggingIn}<Spinner />{/if}
      </button>
    </form>

    <hr />

    <div class="other-options">
      <a
        class="classic-link"
        href="/signup"
        on:click={loadInternalLink}
      >
        {I18n('create an account')}
      </a>
      <a
        class="classic-link"
        href={forgotPasswordHref}
        on:click={loadInternalLink}
      >
        {I18n('forgot your password?')}
      </a>
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#user/scss/auth_menu_commons';
  .auth-menu{
    @include auth-menu-commons;
    @include input-box;
    @include auth-menu-with-other-options;
  }
  button#login{
    margin-block-start: 1em;
  }
  label{
    .complement{
      color: #444;
      font-weight: normal;
      margin-inline-start: 0.2em;
    }
  }
</style>