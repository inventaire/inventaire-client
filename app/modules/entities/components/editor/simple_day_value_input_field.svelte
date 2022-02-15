<script>
  import { i18n, I18n } from 'modules/user/lib/i18n'
  export let value, name, min, max, placeholder, optional = true, closeButtonTitle

  let inputEl

  function initValue () {
    value = value || 1
  }
  $: inputEl && inputEl.focus()
</script>

{#if value || !optional}
  <fieldset>
    <div>
      <label for="{name}">{I18n(name)}</label>
      {#if optional}
        <button
          class="close"
          on:click={() => value = null}
        >
        &#215;
        </button>
      {/if}
    </div>
    <input
      {name}
      type="number"
      {min}
      {max}
      step=1
      value={value}
      {placeholder}
      bind:this={inputEl}
    >
  </fieldset>
{:else}
  <button
    class="tiny-button"
    title={closeButtonTitle}
    on:click={initValue}
    >
    + {i18n(name)}
  </button>
{/if}

<style lang="scss">
  @import 'app/modules/general/scss/utils';
  .tiny-button{
    font-weight: normal;
    white-space: nowrap;
    align-self: flex-end;
    height: 2.3em;
    margin: 0 0.5em 0.1em 0;
    @include shy(0.9);
  }
  input, .tiny-button{
    width: 5em;
  }
  input{
    margin: 0;
  }
  input:invalid{
    border: 2px red solid;
  }
  fieldset{
    margin-right: 0.5em;
    height: 4em;
  }
  fieldset div{
    margin-bottom: 0.1em;
    height: 1.5rem;
    @include display-flex(row, center, flex-start);
  }
  .close{
    font-size: 1.5rem;
    margin: 0 0 0 auto;
    padding: 0;
    line-height: 0;
    height: 100%;
    width: 1.5rem;
    @include shy(0.8);
    @include bg-hover(white);
  }
</style>
