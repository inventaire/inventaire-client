<script>
  import Flash from '#lib/components/flash.svelte'
  import { I18n } from '#user/lib/i18n'
  import { testPassword } from '#user/lib/password_tests'

  export let title
  export let password
  export let flash = null
  export let autocomplete = 'on'

  let showPassword = false

  const togglePassword = () => showPassword = !showPassword

  const changePwd = value => {
    flash = null
    password = value
  }

  function earlyVerifyPassword () {
    try {
      if (password) testPassword(password)
    } catch (err) {
      flash = err
    }
  }
</script>

<!-- Prefer on:input to bind:value as "'type' attribute cannot be dynamic if input uses two-way binding" -->
<label class="main-label">
  <span>{title}</span>
  <input
    type={showPassword ? 'text' : 'password'}
    {autocomplete}
    on:input={e => changePwd(e.target.value)}
    on:blur={earlyVerifyPassword}
    {title}
    name="password"
  />
</label>

<Flash bind:state={flash} />

<div class="show-password-wrapper">
  <label class="inline">
    <input
      type="checkbox"
      class="show-password"
      bind:checked={showPassword}
      on:click={togglePassword}
    />
    {I18n('Show password')}
  </label>
</div>

<style lang="scss">
  input{
    margin: 0;
  }
  input[type="checkbox"]{
    margin-inline-end: 0.5em;
  }
  .main-label span{
    font-size: 1rem;
    margin-block: 1em 0.2em;
    display: block;
  }
  .inline{
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
  }
  .show-password-wrapper{
    padding: 0.5em 0;
    display: flex;
    align-items: center;
  }
  .show-password{
    /* otherwise chrome do not display any checkbox */
    appearance: auto;
  }
</style>
