<script>
  import { i18n } from 'modules/user/lib/i18n'
  export let value, name, min, max, placeholder, optional = true

  let inputEl

  function initValue () {
    value = value || 1
  }
  $: inputEl && inputEl.focus()
</script>

{#if value || !optional}
  <input
    {name}
    type="number"
    {min}
    {max}
    step=1
    bind:value={value}
    {placeholder}
    bind:this={inputEl}
  >
{:else}
  <button
    class="tiny-button"
    on:click={initValue}
    >
    + {i18n(name)}
  </button>
{/if}

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  input{
    margin: 0;
  }
  input, button{
    width: 5rem;
    margin-right: 0.5em;
  }
  button{
    font-weight: normal;
    white-space: nowrap;
    align-self: flex-end;
    height: 2.3em;
    @include shy(0.9);
  }
  input:invalid{
    border: 2px red solid;
  }
</style>
