<!-- This component is a <select> but being empty by default, using it's label as default button label -->
<script>
  import Dropdown from '#components/dropdown.svelte'
  import SelectDropdownOption from '#components/select_dropdown_option.svelte'
  import getActionKey from '#lib/get_action_key'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { I18n } from '#user/lib/i18n'
  import { uniqueId } from 'underscore'

  export let value, displayedOptions, optionsCount, buttonLabel = null

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
    const currentOptionIndex = displayedOptions.indexOf(currentOption)
    const nextOption = displayedOptions[currentOptionIndex + indexIncrement]
    if (nextOption) value = nextOption.value
  }

  let currentOption
  $: {
    if (value != null) {
      currentOption = displayedOptions.find(option => option.value === value)
    } else {
      currentOption = null
    }
  }

  $: buttonDisabled = displayedOptions.length === 0
</script>

<div
  class="facet-selector select-dropdown"
  class:has-image={false}
  class:active={currentOption != null}
  class:disabled={buttonDisabled}
  role="listbox"
  on:keydown={onKeyDown}
  >
  <label class="select-label" for={buttonId}>
    {buttonLabel}
    {#if currentOption == null}
      <span class="options-count">({optionsCount})</span>
      {@html icon('caret-down')}
    {/if}
  </label>
  <Dropdown
    alignButtonAndDropdownWidth={true}
    clickOnContentShouldCloseDropdown={true}
    {buttonId}
    buttonRole="listbox"
    {buttonDisabled}
    >
    <div slot="button-inner">
      {#if currentOption}
        <SelectDropdownOption option={currentOption} withImage={true} displayCount={false} />
        <button
          class="reset"
          title={I18n('reset filter')}
          aria-controls="language-filter"
          on:click|stopPropagation={() => value = null}
        >{@html icon('close')}</button>
      {/if}
    </div>
    <div slot="dropdown-content" role="presentation">
      {#each displayedOptions as option (option.value)}
        <button
          role="option"
          title={option.text}
          data-value={option.value}
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
  .facet-selector{
    position: relative;
    min-width: 12em;
    margin: 0.8em 0.5em 0.2em 0.5em;
    // Always set a border, only change its color when needed
    // to avoid dimensions changes
    border: 1px solid transparent;
    &:not(.active){
      label{
        font-weight: bold;
        color: $dark-grey;
        transform: translateY(1.3rem);
        z-index: 1;
      }
    }
    &.active{
      border-color: $light-blue;
      label{
        transform: translateY(-0.6rem);
      }
    }
    &.disabled{
      label{
        opacity: 0.6;
      }
    }
    :global(.dropdown-button){
      word-break: normal;
      @include bg-hover(white, 8%);
      @include radius;
      @include shy-border;
      font-weight: bold;
      color: $dark-grey;
    }
  }
  [slot="button-inner"], .reset{
    height: 2.5em;
  }
  label{
    line-height: 0;
    font-size: 1rem;
    @include display-flex(row);
    @include transition;
    position: relative;
    text-align: left;
    margin: 0 1em;
    :global(.fa-caret-down){
      line-height: 0;
      margin-left: auto;
    }
  }
  .options-count{
    font-weight: normal;
    color: $grey;
    margin-left: 0.3rem;
  }
  [role="option"][data-value="unknown"]{
    @include shy;
  }
</style>
