<script>
  import SelectDropdownOption from '#components/select_dropdown_option.svelte'
  import getActionKey from '#lib/get_action_key'
  import { uniqueId } from 'underscore'

  export let value, options, buttonLabel = null, withImage = false

  const buttonId = uniqueId('button')

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'up') selectNext(-1)
    else if (key === 'down') selectNext(1)
    else return
    e.stopPropagation()
    e.preventDefault()
  }

  $: currentOption = options.find(option => option.value === value) || {}

  function selectNext (indexIncrement) {
    const currentOptionIndex = options.indexOf(currentOption)
    const nextOption = options[currentOptionIndex + indexIncrement]
    if (nextOption) value = nextOption.value
  }
  function toggleOption () {
    const toggledOption = options.find(opt => opt.value !== value)
    value = toggledOption.value
  }

</script>

<div
  class="select-dropdown"
  class:has-image={withImage}
  on:keydown={onKeyDown}
>
  {#if buttonLabel}
    <label for={buttonId}>{buttonLabel}</label>
  {/if}
  <button
    title={currentOption.text}
    aria-selected={currentOption.value === value}
    class="button-toggler"
    on:click={toggleOption}
  >
    {#key currentOption}
      <SelectDropdownOption option={currentOption} {withImage} />
    {/key}
  </button>
</div>

<style lang="scss">
  @import '#general/scss/select_dropdown_commons';
  .button-toggler{
    @include shy-border;
    padding: 0.5em;
  }
</style>
