<script>
  import { autofocus } from '#lib/components/actions/autofocus'
  import { i18n } from '#user/lib/i18n'
  import { BubbleUpComponentEvent } from '#lib/svelte/svelte'
  import error_ from '#lib/error'

  export let currentValue, getInputValue, editorType

  const bubbleUpEvent = BubbleUpComponentEvent()

  let input
  getInputValue = () => {
    const { value } = input
    if (!input.validity.valid) {
      throw error_.new('invalid value', 400, { value })
    }
    if (editorType === 'positive-integer-string') return input.value
    else return parseInt(input.value)
  }
</script>

<input
  type="number"
  min=1
  max=100000
  step=1
  placeholder="{i18n('ex:')} 254"
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
