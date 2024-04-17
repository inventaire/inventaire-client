<script context="module" lang="ts">
  export type Align = 'left' | 'center' | 'right'
</script>
<script lang="ts">
  import { tick } from 'svelte'
  import { slide } from 'svelte/transition'
  import { isFunction } from 'underscore'
  import { screen } from '#app/lib/components/stores/screen'
  import { getActionKey } from '#app/lib/key_events'
  import { getViewportHeight, getViewportWidth } from '#app/lib/screen'
  import { convertEmToPx } from '#app/lib/utils'

  export let buttonTitle = null
  export let align: Align = null
  export let dropdownWidthReferenceEl = null
  export let alignDropdownWidthOnButton = false
  export let alignButtonWidthOnDropdown = false
  export let dropdownWidthBaseInEm = null
  export let clickOnContentShouldCloseDropdown: boolean | ((e: CustomEvent) => boolean) = false
  export let buttonId = null
  export let buttonRole = null
  export let buttonDisabled = false
  export let transitionDuration = 100
  export let showDropdown = false

  let positionned = false
  let buttonWithDropdown, dropdown, dropdownPositionRight, dropdownPositionLeft, dropdownWrapperEl
  let buttonWidth, dropdownWidth

  function onButtonClick () {
    showDropdown = !showDropdown
    if (showDropdown) setTimeout(refreshPositionAndScroll)
  }

  function refreshPositionAndScroll () {
    adjustDropdownPosition()
    // Trigger after transition
    setTimeout(scrollToDropdownIfNeeded, transitionDuration + 10)
  }

  let inferredAlign
  async function adjustDropdownPosition () {
    if (!dropdown) return
    dropdownPositionLeft = null
    dropdownPositionRight = null
    inferredAlign = align
    const buttonRect = buttonWithDropdown.getBoundingClientRect()
    const dropdownRect = dropdown.getBoundingClientRect()
    const buttonDistanceFromViewportLeftSide = buttonRect.left
    const buttonDistanceFromRViewportightSide = getViewportWidth() - buttonRect.right
    if (!align) {
      inferredAlign = (buttonDistanceFromViewportLeftSide > buttonDistanceFromRViewportightSide) ? 'right' : 'left'
    }
    if (inferredAlign === 'right') dropdownPositionRight = 0
    else if (inferredAlign === 'left') dropdownPositionLeft = 0
    else if (inferredAlign === 'center') {
      dropdownPositionLeft = (buttonRect.width / 2) - (dropdownRect.width / 2)
    }
    // Let the time to the previous adjustments to take effects
    await tick()
    if (!dropdown) return
    const dropdownRectAfter = dropdown.getBoundingClientRect()
    const dropdownOverflowsOnViewportLeft = dropdownRectAfter.x < 0
    const dropdownOverflowsOnViewportRight = (dropdownRectAfter.x + dropdownRectAfter.width) > getViewportWidth()
    if (dropdownOverflowsOnViewportLeft || dropdownOverflowsOnViewportRight) {
      const viewportLeftBorderFromButtonLeft = -buttonRect.x
      const viewportRightBorderFromButtonRight = buttonRect.x + buttonRect.width - getViewportWidth()
      // Positioning the dropdown to cover the whole viewport width
      // by using position values relative to the button
      dropdownPositionLeft = viewportLeftBorderFromButtonLeft
      dropdownPositionRight = viewportRightBorderFromButtonRight
    }
    positionned = true
  }

  function scrollToDropdownIfNeeded () {
    if (!dropdown) return
    const dropdownRect = dropdown.getBoundingClientRect()
    if (dropdownRect.bottom > getViewportHeight()) {
      if (dropdownRect.height > getViewportHeight()) {
        dropdown.scrollIntoView({ block: 'start', inline: 'nearest', behavior: 'smooth' })
      } else {
        dropdown.scrollIntoView({ block: 'end', inline: 'nearest', behavior: 'smooth' })
      }
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
      if (showDropdown) {
        showDropdown = false
        // Do not stop propagation if the dropdown is already closed
        // to let parent components bind actions to an esc key
        e.stopPropagation()
      }
    }
  }
  $: {
    if (alignDropdownWidthOnButton && buttonWithDropdown) {
      dropdownWidth = buttonWithDropdown.getBoundingClientRect().width
    } else if (alignButtonWidthOnDropdown && dropdown) {
      buttonWidth = dropdown.getBoundingClientRect().width
    } else if (dropdownWidthReferenceEl) {
      dropdownWidth = dropdownWidthReferenceEl.getBoundingClientRect().width
    } else if (dropdownWidthBaseInEm) {
      dropdownWidth = convertEmToPx(dropdownWidthBaseInEm)
    } else {
    // A width/min-width/inline-size/min-inline-size should be set on .dropdown-content from the outside
    }
    if (dropdownWidth && dropdownWidth > $screen.width) dropdownWidth = $screen.width
  }
</script>

<svelte:body on:click={onOutsideClick} />
<svelte:window on:resize={refreshPositionAndScroll} />

<div
  class="has-dropdown"
  bind:this={dropdownWrapperEl}
  on:keydown={onKeyDown}
  role="menu"
  tabindex="-1"
>
  <button
    class="dropdown-button"
    title={buttonTitle}
    id={buttonId}
    aria-haspopup="menu"
    role={buttonRole}
    disabled={buttonDisabled}
    style:width={buttonWidth}
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
      style:inset-inline-end={dropdownPositionRight != null ? `${dropdownPositionRight}px` : null}
      style:inset-inline-start={dropdownPositionLeft != null ? `${dropdownPositionLeft}px` : null}
      style:width={dropdownWidth != null ? `${dropdownWidth}px` : null}
      role="menu"
      tabindex="-1"
      transition:slide={{ duration: transitionDuration }}
      on:click={onContentClick}
      on:keydown
    >
      <slot name="dropdown-content" />
    </div>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .has-dropdown{
    position: relative;
    @include display-flex(row, stretch, center);
  }
  .dropdown-button{
    flex: 1;
  }
  button:disabled{
    opacity: 0.6;
  }
  .dropdown-content{
    position: absolute;
    inset-block-start: 100%;
    z-index: 11;
    // Add a bit of padding so that there will be a bit of margin down
    // when scrolling to get the dropdown content in the viewport
    padding-block-end: 0.5em;
    overflow-x: hidden;
  }
</style>
