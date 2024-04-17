<script lang="ts">
  import { icon } from '#app/lib/icons'

  export let show = false
  export let moreText: string
  export let lessText: string = null
  export let scrollTopElement = null
  export let withIcon = true
  export let remainingCounter = 0

  function toggle () {
    show = !show
    if (!show && scrollTopElement) {
      scrollTopElement.scrollIntoView({ behavior: 'smooth' })
    }
  }
</script>

{#if show}
  {#if lessText}
    <button
      class="wrap-toggler"
      on:click|stopPropagation={toggle}
    >
      {#if withIcon}
        {@html icon('chevron-up')}
      {/if}
      {lessText}
    </button>
  {/if}
{:else}
  <button
    class="wrap-toggler"
    on:click|stopPropagation={toggle}
  >
    {#if withIcon}
      {@html icon('chevron-down')}
    {/if}
    {moreText}
    {#if remainingCounter > 0}
      ({remainingCounter})
    {/if}
  </button>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  button{
    display: block;
    @include shy;
  }
</style>
