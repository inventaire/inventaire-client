<!-- This component mimicks a <select>
     See https://developer.mozilla.org/en-US/docs/Learn/Forms/How_to_build_custom_form_controls -->
<script>
  import Dropdown from '#components/dropdown.svelte'
  import SelectDropdownOption from '#components/select_dropdown_option.svelte'
  import getActionKey from '#lib/get_action_key'
  import { icon } from '#lib/handlebars_helpers/icons'
  import { I18n } from '#user/lib/i18n'
  import { uniqueId } from 'underscore'

  export let value, resetValue = null, options, buttonLabel = null, withImage = false

  const buttonId = uniqueId('label')

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

  $: currentOption = options.find(option => option.value === value)
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
    alignButtonAndDropdownWidth={true}
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
          aria-controls="language-filter"
          on:click|stopPropagation={() => value = resetValue}
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
          <SelectDropdownOption {option} {withImage} />
        </button>
      {/each}
    </div>
  </Dropdown>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .select-dropdown{
    display: inline-block;
    :global(.fa){
      margin-right: 0.5em;
    }
    :global(.dropdown-button){
      font-weight: normal;
      @include shy-border;
      padding: 0;
      &:focus{
        border-color: $glow;
      }
    }
    &:not(.has-image){
      [slot="button-inner"], [role="option"]{
        padding: 0.5em;
      }
    }
    &.has-image{
      [slot="button-inner"], [role="option"]{
        padding: 0;
      }
    }
  }
  label{
    text-align: center;
  }
  [slot="button-inner"], [role="option"]{
    @include bg-hover(white, 5%);
    @include display-flex(row, center, center);
  }
  [slot="button-inner"]{
    position: relative;
  }
  .reset{
    position: absolute;
    width: 2em;
    height: 2em;
    right: 0;
    top: 0;
    text-align: center;
    @include shy(0.9);
    @include bg-hover(white);
    padding: 0;
    :global(.fa){
      padding: 0;
      margin: 0;
      line-height: 0;
    }
  }
  [slot="dropdown-content"]{
    @include display-flex(column, stretch);
    background-color: white;
    @include shy-border;
    @include radius-bottom;
    max-height: 50vh;
    overflow-y: auto;
    overflow-x: hidden;
  }
  [role="option"]{
    @include radius(0);
    border-bottom: 1px solid #ddd;
    &[aria-selected=true]{
      background-color: darken(white, 5%);
    }
  }
</style>
