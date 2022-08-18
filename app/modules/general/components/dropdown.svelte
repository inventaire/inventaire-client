<script>
  import { isFunction } from 'underscore'
  import { slide } from 'svelte/transition'
  import getActionKey from '#lib/get_action_key'

  export let buttonTitle
  export let align = null
  export let widthReferenceEl
  export let alignButtonAndDropdownWidth = false
  export let clickOnContentShouldCloseDropdown = false
  export let buttonId = null
  export let buttonRole = null

  let showDropdown = false, positionned = false
  let buttonWithDropdown, dropdown, dropdownPositionRight, dropdownPositionLeft, dropdownWrapperEl
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

  function getReferenceElWidth () {
    return widthReferenceEl.getBoundingClientRect().width
  }

  function scrollToDropdownIfNeeded () {
    if (!dropdown) return
    const dropdownRect = dropdown.getBoundingClientRect()
    if (dropdownRect.bottom > window.visualViewport.height) {
      dropdown.scrollIntoView({ block: 'end', inline: 'nearest', behavior: 'smooth' })
    }
  }

  function onOutsideClick (e) {
    if (!(dropdownWrapperEl.contains(e.target) || isButtonLabel(e.target))) {
      showDropdown = false
    }
  }

  const isButtonLabel = target => {
    const labelEl = document.querySelector(`label[for="${buttonId}"]`)
    if (!labelEl) return false
    return target === labelEl || labelEl.contains(target)
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

  function onKeyDown (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      showDropdown = false
      e.stopPropagation()
    }
  }

  $: if (alignButtonAndDropdownWidth) widthReferenceEl = buttonWithDropdown
</script>

<svelte:body on:click={onOutsideClick} />
<svelte:window on:resize={refreshPositionAndScroll} />

<div
  class="has-dropdown"
  bind:this={dropdownWrapperEl}
  on:keydown={onKeyDown}
  >
  <button
    class="dropdown-button"
    title={buttonTitle}
    id={buttonId}
    aria-haspopup="menu"
    role={buttonRole}
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
      style:width={widthReferenceEl ? `${getReferenceElWidth()}px` : null }
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
    z-index: 10;
    white-space: nowrap;
    // Add a bit of padding so that there will be a bit of margin down
    // when scrolling to get the dropdown content in the viewport
    padding-bottom: 0.5em;
    overflow-x: hidden;
  }
</style>
