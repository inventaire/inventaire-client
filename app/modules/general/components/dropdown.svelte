<script>
  import { isFunction } from 'underscore'
  import { slide } from 'svelte/transition'

  export let buttonTitle
  export let align = null
  export let alignButtonAndDropdownWidth = false
  export let clickOnContentShouldCloseDropdown = false

  let showDropdown = false, positionned = false
  let buttonWithDropdown, dropdown, dropdownPositionRight, dropdownPositionLeft
  const transitionDuration = 100

  function onButtonClick () {
    showDropdown = !showDropdown
    if (showDropdown) setTimeout(refreshPositionAndScroll)
  }

  function refreshPositionAndScroll () {
    adjustDropdownPosition()
    // Trigger after transition
    setTimeout(scrollToDropdownIfNeeded, transitionDuration + 10)
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

  function getButtonWidth () {
    return buttonWithDropdown.getBoundingClientRect().width
  }

  function scrollToDropdownIfNeeded () {
    if (!dropdown) return
    const dropdownRect = dropdown.getBoundingClientRect()
    if (dropdownRect.bottom > window.visualViewport.height) {
      dropdown.scrollIntoView({ block: 'end', inline: 'nearest', behavior: 'smooth' })
    }
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
<svelte:window on:resize={refreshPositionAndScroll} />

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
      style:width={alignButtonAndDropdownWidth ? `${getButtonWidth()}px` : null }
      role="menu"
      transition:slide={{ duration: transitionDuration }}
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
    // Add a bit of padding so that there will be a bit of margin down
    // when scrolling to get the dropdown content in the viewport
    padding-bottom: 0.5em;
  }
</style>
