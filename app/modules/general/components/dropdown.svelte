<script>
  export let buttonTitle

  let showDropdown = false
  let alignRight = false
  let buttonWithDropdown

  function onButtonClick () {
    showDropdown = !showDropdown
    if (showDropdown) adjustDropdownPosition()
  }

  function adjustDropdownPosition () {
    const { left, right } = buttonWithDropdown.getBoundingClientRect()
    const distanceFromLeftScreenSide = left
    const distanceFromRightScreenSide = window.screen.width - right
    alignRight = (distanceFromLeftScreenSide > distanceFromRightScreenSide)
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
    class:show={showDropdown}
    class:align-right={alignRight}
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
    &.align-right{
      right: 0;
    }
    &:not(.align-right){
      left: 0;
    }
  }
</style>
