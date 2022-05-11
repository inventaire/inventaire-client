<script>
  export let buttonTitle, align = null

  let showDropdown = false
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
  }
  function onOutsideClick () {
    showDropdown = false
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
  <div
    class="dropdown-content"
    bind:this={dropdown}
    class:show={showDropdown}
    style:right={dropdownPositionRight != null ? `${dropdownPositionRight}px` : null}
    style:left={dropdownPositionLeft != null ? `${dropdownPositionLeft}px` : null}
    role="menu"
    >
    <slot name="dropdown-content" />
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .has-dropdown{
    position: relative;
  }
  .dropdown-content{
    position: absolute;
    top: 100%;
    z-index: 1;
    white-space: nowrap;
    &:not(.show){
      display: none;
    }
  }
</style>
