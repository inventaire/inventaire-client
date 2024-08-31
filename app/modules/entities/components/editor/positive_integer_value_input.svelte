<script lang="ts">
  import { tick } from 'svelte'
  import { autofocus } from '#app/lib/components/actions/autofocus'
  import { newError } from '#app/lib/error'
  import { BubbleUpComponentEvent } from '#app/lib/svelte/svelte'
  import { i18n } from '#user/lib/i18n'

  export let currentValue, getInputValue, datatype

  const bubbleUpEvent = BubbleUpComponentEvent()

  let input
  getInputValue = async () => {
    // Wait for input to be mounted
    await tick()
    const { value } = input
    if (!input.validity.valid) {
      throw newError('invalid value', 400, { value })
    }
    if (datatype === 'positive-integer-string') return input.value
    else return parseInt(input.value)
  }
</script>

<input
  type="number"
  min="1"
  max="100000"
  step="1"
  placeholder="{i18n('ex:')} 254"
  value={currentValue || ''}
  on:keyup={bubbleUpEvent}
  bind:this={input}
  use:autofocus
/>

<style>
  input{
    margin: 0 auto 0 0;
    padding: 0.4em;
  }
  input:invalid{
    border: 2px red solid;
  }
</style>
