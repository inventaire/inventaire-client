<script>
  import { isFunction } from 'underscore'

  export let buttonTitle
  export let align = null
  export let clickOnContentShouldCloseDropdown = false

  let showDropdown = false, positionned = false
  let buttonWithDropdown, dropdown, dropdownPositionRight, dropdownPositionLeft

  function onButtonClick () {
    showDropdown = !showDropdown
    if (showDropdown) setTimeout(adjustDropdownPosition)
  }

  function adjustDropdownPosition () {
    const buttonRect = buttonWithDropdown.getBoundingClientRect()
    const buttonDistanceFromLeftScreenSide = buttonRect.left
    const buttonDistanceFromRightScreenSide = window.screen.width - buttonRect.right
    if (!align) {
      align = (buttonDistanceFromLeftScreenSide > buttonDistanceFromRightScreenSide) ? 'right' : 'left'
    }
    if (align === 'right') dropdownPositionRight = 0
    else if (align === 'left') dropdownPositionLeft = 0
    else if (align === 'center') {
      const dropdownRect = dropdown.getBoundingClientRect()
      dropdownPositionLeft = (buttonRect.width / 2) - (dropdownRect.width / 2)
    }
    positionned = true
  }
  function onOutsideClick () {
    showDropdown = false
  }
  function onContentClick (e) {
    if (isFunction(clickOnContentShouldCloseDropdown)) {
      if (clickOnContentShouldCloseDropdown(e)) {
        showDropdown = false
      }
    } else if (clickOnContentShouldCloseDropdown === true) {
      showDropdown = false
    }
  }
</script>

<svelte:body on:click={onOutsideClick} />
<svelte:window on:resize={adjustDropdownPosition} />

<div
  class="has-dropdown"
  on:click|stopPropagation
  >
  <button
    class="dropdown-button"
    title={buttonTitle}
    aria-haspopup="menu"
    bind:this={buttonWithDropdown}
    on:click={onButtonClick}
    >
    <slot name="button-inner" />
  </button>
  {#if showDropdown}
    <div
      class="dropdown-content"
      bind:this={dropdown}
      class:show={showDropdown}
      style:visibility={positionned ? 'visible' : 'hidden'}
      style:right={dropdownPositionRight != null ? `${dropdownPositionRight}px` : null}
      style:left={dropdownPositionLeft != null ? `${dropdownPositionLeft}px` : null}
      role="menu"
      on:click={onContentClick}
      >
      <slot name="dropdown-content" />
    </div>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .has-dropdown{
    position: relative;
    @include display-flex(row, stretch, center);
  }
  .dropdown-button{
    flex: 1;
  }
  .dropdown-content{
    position: absolute;
    top: 100%;
    z-index: 1;
    white-space: nowrap;
  }
</style>
