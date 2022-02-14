<script>
  import { autofocus } from 'lib/components/actions/autofocus'
  import { createEventDispatcher } from 'svelte'

  export let currentValue, getInputValue

  const dispatch = createEventDispatcher()

  let input
  getInputValue = () => input.value
</script>

<input
  type="text"
  value={currentValue || ''}
  on:keyup={e => dispatch('keyup', e)}
  bind:this={input}
  use:autofocus
>

<style>
  input{
    margin: 0;
  }
</style>
