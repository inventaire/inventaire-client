<!-- This component mimicks a <select>
     See https://developer.mozilla.org/en-US/docs/Learn/Forms/How_to_build_custom_form_controls -->
<script>
  import Dropdown from '#components/dropdown.svelte'
  import SelectDropdownOption from '#components/select_dropdown_option.svelte'
  import getActionKey from '#lib/get_action_key'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { I18n } from '#user/lib/i18n'
  import { uniqueId } from 'underscore'

  export let value, resetValue = null, options, buttonLabel = null, withImage = false, hideCurrentlySelectedOption = false
  const buttonId = uniqueId('button')

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'up') selectNext(-1)
    else if (key === 'down') selectNext(1)
    else return
    e.stopPropagation()
    e.preventDefault()
  }

  $: currentOption = options.find(option => option.value === value)

  function selectNext (indexIncrement) {
    const currentOptionIndex = options.indexOf(currentOption)
    const nextOption = options[currentOptionIndex + indexIncrement]
    if (nextOption) value = nextOption.value
  }
</script>

<div
  class="select-dropdown"
  class:has-image={withImage}
  role="listbox"
  on:keydown={onKeyDown}
>
  {#if buttonLabel}
    <label for={buttonId}>{buttonLabel}</label>
  {/if}
  <Dropdown
    alignButtonWidthOnDropdown={true}
    clickOnContentShouldCloseDropdown={true}
    {buttonId}
    buttonRole="listbox"
  >
    <div slot="button-inner">
      <SelectDropdownOption option={currentOption} {withImage} />
      {#if resetValue && value !== resetValue}
        <button
          class="reset"
          title={I18n('reset filter')}
          on:click|stopPropagation={() => value = resetValue}
        >{@html icon('close')}</button>
      {/if}
    </div>
    <div slot="dropdown-content" role="presentation">
      {#each options as option}
        {#if !(hideCurrentlySelectedOption && option.value === value)}
          <button
            role="option"
            title={option.text}
            aria-selected={option.value === value}
            on:click={() => value = option.value}
          >
            <SelectDropdownOption {option} {withImage} />
          </button>
        {/if}
      {/each}
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import "#general/scss/select_dropdown_commons";
</style>
