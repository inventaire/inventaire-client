<!-- This component mimicks a <select>
     See https://developer.mozilla.org/en-US/docs/Learn/Forms/How_to_build_custom_form_controls -->
<script>
  import { createEventDispatcher } from 'svelte'
  import { uniqueId } from 'underscore'
  import Dropdown from '#components/dropdown.svelte'
  import SelectDropdownOption from '#components/select_dropdown_option.svelte'
  import Spinner from '#general/components/spinner.svelte'
  import { icon } from '#lib/icons'
  import { getActionKey } from '#lib/key_events'
  import { I18n } from '#user/lib/i18n'

  const dispatch = createEventDispatcher()

  export let value
  export let resetValue = null
  export let options
  export let buttonLabel = null
  export let withImage = false
  export let hideCurrentlySelectedOption = false
  export let loadingMessage = null
  export let waitingForOptions = null

  const buttonId = uniqueId('button')

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'up') selectNext(-1)
    else if (key === 'down') selectNext(1)
    else return
    e.stopPropagation()
    e.preventDefault()
  }

  const optionPlaceholder = { value: 'all', text: I18n('all') }
  $: currentOption = options?.find(option => option.value === value) || optionPlaceholder

  function selectNext (indexIncrement) {
    const currentOptionIndex = options.indexOf(currentOption)
    const nextOption = options[currentOptionIndex + indexIncrement]
    if (nextOption) value = nextOption.value
  }

  function assignNewValue (option) {
    if (value === option.value) {
      dispatch('selectSameOption')
    } else {
      value = option.value
    }
  }
</script>

<div
  class="select-dropdown"
  class:has-image={withImage}
  role="listbox"
  on:keydown={onKeyDown}
  tabindex="-1"
>
  {#if buttonLabel}
    <!-- Set the title in case the text overflow is hidden -->
    <label for={buttonId} title={buttonLabel}>{buttonLabel}</label>
  {/if}
  <Dropdown
    alignButtonWidthOnDropdown={true}
    clickOnContentShouldCloseDropdown={true}
    {buttonId}
    buttonRole="listbox"
  >
    <div slot="button-inner">
      <SelectDropdownOption option={currentOption} {withImage} promise={currentOption.promise} />
      {#if resetValue && value !== resetValue}
        <button
          class="reset"
          title={I18n('reset filter')}
          on:click|stopPropagation={() => value = resetValue}
        >{@html icon('close')}</button>
      {/if}
    </div>
    <div slot="dropdown-content" role="presentation">
      {#await waitingForOptions}
        <div class="loading-message">
          <Spinner />
          {#if loadingMessage}<p>{loadingMessage}</p>{/if}
        </div>
      {:then}
        {#each options as option}
          {#if !(hideCurrentlySelectedOption && option.value === value)}
            <button
              role="option"
              title={option.text}
              aria-selected={option.value === value}
              on:click={() => assignNewValue(option)}
            >
              <SelectDropdownOption {option} {withImage}>
                <div slot="line-end">
                  {#if option.value === value}
                    <slot name="selected-option-line-end" />
                  {/if}
                </div>
              </SelectDropdownOption>
            </button>
          {/if}
        {/each}
      {/await}
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import "#general/scss/select_dropdown_commons";
  label{
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
  .loading-message{
    margin: 1em 0;
    padding: 0 1em;
    text-align: center;
    white-space: break-spaces;
  }
</style>
