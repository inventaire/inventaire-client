<!-- This component is a <select> but being empty by default, using it's label as default button label -->
<script>
  import Dropdown from '#components/dropdown.svelte'
  import SelectDropdownOption from '#components/select_dropdown_option.svelte'
  import getActionKey from '#lib/get_action_key'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { I18n } from '#user/lib/i18n'
  import { uniqueId } from 'underscore'

  export let value, options, buttonLabel = null

  const buttonId = uniqueId('button')

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'up') selectNext(-1)
    else if (key === 'down') selectNext(1)
    else return
    e.stopPropagation()
    e.preventDefault()
  }

  function selectNext (indexIncrement) {
    const currentOptionIndex = options.indexOf(currentOption)
    const nextOption = options[currentOptionIndex + indexIncrement]
    if (nextOption) value = nextOption.value
  }

  let currentOption
  $: {
    if (value != null) {
      currentOption = options.find(option => option.value === value)
    } else {
      currentOption = null
    }
  }
</script>

<div
  class="select-dropdown"
  class:has-image={false}
  class:active={currentOption != null}
  role="listbox"
  on:keydown={onKeyDown}
  >
  <label class="select-label" for={buttonId}>{buttonLabel}</label>
  <Dropdown
    alignButtonAndDropdownWidth={true}
    clickOnContentShouldCloseDropdown={true}
    {buttonId}
    buttonRole="listbox"
    >
    <div slot="button-inner">
      {#if currentOption}
        <SelectDropdownOption option={currentOption} withImage={false} displayCount={false} />
        <button
          class="reset"
          title={I18n('reset filter')}
          aria-controls="language-filter"
          on:click={() => value = null}
        >{@html icon('close')}</button>
      {/if}
    </div>
    <div slot="dropdown-content" role="presentation">
      {#each options as option}
        <button
          role="option"
          title={option.text}
          aria-selected={option.value === value}
          on:click={() => value = option.value}
          >
          <SelectDropdownOption {option} withImage={true} />
        </button>
      {/each}
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import '#general/scss/select_dropdown_commons';
  .select-dropdown{
    position: relative;
    &:not(.active){
      label{
        font-weight: bold;
        color: $dark-grey;
        transform: translateY(1.3rem);
      }
    }
    &.active{
      label{
        transform: translateY(-0.6rem);
      }
    }
  }
  [slot="button-inner"], .reset{
    height: 2.5em;
  }
  label{
    line-height: 0;
    font-size: 1rem;
    @include transition;
    position: relative;
    text-align: left;
    margin: 0 1em;
    z-index: 1;
  }
</style>
