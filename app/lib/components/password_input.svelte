<script>
  import Flash from '#lib/components/flash.svelte'
  import { I18n } from '#modules/user/lib/i18n'

  export let password, flash, title
  export let autocomplete = 'on'
  let showPassword = false

  const togglePassword = () => showPassword = !showPassword

  const changePwd = value => {
    flash = null
    password = value
  }

  $: pwdInputType = showPassword ? 'text' : 'password'
</script>

<!--
Prefer on:change to bind:value since svelte cannot dynamically change a value if another one is binded.
aka `type={pwdInputType} bind:value={password}` is forbidden since generated code is different for different kinds of input. -->
<label class="main-label">
  <span>{title}</span>
  <input type={pwdInputType} autocomplete={autocomplete} on:change="{e => changePwd(e.target.value) }" title={title} name="password">
</label>

<Flash bind:state={flash}/>
<div class="showPasswordWrapper">
  <label class="inline">
    <input type="checkbox" class="showPassword" bind:checked={showPassword} on:click={togglePassword}>
    {I18n('Show password')}
  </label>
</div>

<style lang="scss">
  input{
    margin: 0;
  }
  input[type=checkbox]{
    margin-right: 0.5em;
  }
  .main-label span{
    font-size: 1rem;
    margin-top: 1em;
    margin-bottom: 0.2em;
    display: block;
  }
  .inline{
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
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
