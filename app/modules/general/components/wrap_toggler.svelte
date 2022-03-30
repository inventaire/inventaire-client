<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  export let show, moreText, lessText
</script>

{#if show}
  {#if lessText}
    <button
      class="wrap-toggler"
      on:click={() => show = false}
      >
      {@html icon('chevron-up')}
      {lessText}
    </button>
  {/if}
{:else}
  <button
    class="wrap-toggler"
    on:click={() => show = true}
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
