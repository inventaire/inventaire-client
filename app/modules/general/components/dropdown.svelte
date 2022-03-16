<script>
  export let alignRight = false, buttonTitle

  let showDropdown = false

  function onOutsideClick () {
    showDropdown = false
  }
</script>

<svelte:body on:click={onOutsideClick} />

<div
  class="has-dropdown"
  on:click|stopPropagation
  >
  <button
    class="dropdown-button"
    title={buttonTitle}
    aria-haspopup="menu"
    on:click={() => showDropdown = !showDropdown}
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
