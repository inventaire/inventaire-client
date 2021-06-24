<script>
  import Flash from 'lib/components/flash.svelte'
  import { I18n } from 'modules/user/lib/i18n'

  export let password, flash, name
  let pwdInputType = 'password'
  let showPassword

  const togglePassword = () => {
    showPassword = !showPassword
    if (pwdInputType === 'password') {
      pwdInputType = 'text'
    } else {
      pwdInputType = 'password'
    }
  }
  const changePwd = value => {
    flash = null
    password = value
  }
</script>

<!--
Prefer on:change to bind:value since svelte cannot dynamically change a value if another one is binded.
aka `type={pwdInputType} bind:value={password}` is forbidden since generated code is different for different kinds of input. -->
<input type={pwdInputType} on:change="{e => changePwd(e.target.value) }" title={name}>
<Flash bind:state={flash}/>
<div class="showPasswordWrapper">
  <input type="checkbox" class="showPassword" id="show{name}" bind:checked={showPassword} on:click={togglePassword}>
  <label for="show{name}">{I18n('Show password')}</label>
</div>

<style lang="scss">
  input{
    margin: 0;
  }
  .showPasswordWrapper{
    padding: 0.5em 0;
    display: flex;
    align-items: center;
  }
  .showPassword{
    /*otherwise chrome do not display any checkbox*/
    appearance: auto;
  }
</style>
