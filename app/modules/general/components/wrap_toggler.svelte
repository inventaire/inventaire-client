<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  export let show = false, moreText, lessText, scrollTopElement

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
      on:click={toggle}
      >
      {@html icon('chevron-up')}
      {lessText}
    </button>
  {/if}
{:else}
  <button
    class="wrap-toggler"
    on:click={toggle}
    >
    {@html icon('chevron-down')}
    {moreText}
  </button>
{/if}

<style lang="scss">
  @import '#general/scss/utils';
  button{
    display: block;
    @include shy;
  }
</style>
