<script>
  import { autofocus } from '#lib/components/actions/autofocus'
  import error_ from '#lib/error'
  import { BubbleUpComponentEvent } from '#lib/svelte'

  export let currentValue, getInputValue

  const bubbleUpEvent = BubbleUpComponentEvent()

  let input
  getInputValue = () => {
    const { value } = input
    if (!input.validity.valid) {
      throw error_.new('invalid value', 400, { value })
    }
    return input.value
  }
</script>

<input
  type="text"
  value={currentValue || ''}
  on:keyup={bubbleUpEvent}
  bind:this={input}
  use:autofocus
>

<style>
  input{
    margin: 0 0.2em 0 0;
  }
  input:invalid{
    border: 2px red solid;
  }
</style>