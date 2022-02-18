<script>
  import { i18n } from '#user/lib/i18n'
  import { createEventDispatcher } from 'svelte'
  import { BubbleUpComponentEvent } from '#lib/utils'

  export let value, name, min, max, placeholder, optional = true, componentId

  let inputEl

  const dispatch = createEventDispatcher()
  const bubbleUpEvent = BubbleUpComponentEvent(dispatch)

  function initValue () {
    value = value || 1
  }

  $: inputEl && inputEl.focus()
</script>

{#if value || !optional}
  <input
    type="number"
    id="{componentId}-{name}"
    {name}
    {min}
    {max}
    step=1
    bind:value={value}
    on:keyup={bubbleUpEvent}
    {placeholder}
    bind:this={inputEl}
  >
{:else}
  <button
    title={i18n(`Precise the date to the ${name}`)}
    class="tiny-button"
    on:click={initValue}
    on:keyup={bubbleUpEvent}
  >
    + {i18n(name)}
  </button>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
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
