<script>
  import Flash from 'lib/components/flash.svelte'
  import { I18n } from 'modules/user/lib/i18n'

  export let password, showFlash, name
  let pwdInputType = 'password'
  let showPassword, hideFlash

  const togglePassword = () => {
    showPassword = !showPassword
    if (pwdInputType === 'password') {
      pwdInputType = 'text'
    } else {
      pwdInputType = 'password'
    }
  }
  const changePwd = value => password = value
</script>

<input type={pwdInputType} on:blur={hideFlash} on:blur="{e => changePwd(e.target.value) }" title="{name}">
<Flash bind:show={showFlash} bind:hide={hideFlash}/>
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
