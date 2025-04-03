<script lang="ts">
  import { slide } from 'svelte/transition'
  import { icon as iconFn } from '#app/lib/icons'
  import { scrollToElement } from '#app/lib/screen'

  export let icon
  export let summary
  export let open = false

  let sectionEl

  function toggle () {
    open = !open
    if (open) scrollToElement(sectionEl)
  }
</script>

<div class="foldable-section" class:open bind:this={sectionEl}>
  <button class="toggle-details" on:click={toggle}>
    <span class="icon">{@html iconFn(icon)}</span>
    {summary}
    {@html iconFn('caret-right')}
  </button>
  {#if open}
    <div class="content" transition:slide>
      <slot />
    </div>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .foldable-section{
    @include display-flex(column, stretch);
    :global(.fa-caret-right){
      margin-inline-start: auto;
      @include display-flex(row, center, center);
      margin-block-start: -0.2em;
      font-size: 1.5em;
      opacity: 0.5;
      @include transition(transform, 0.2s);
    }
    &.open{
      :global(.fa-caret-right){
        transform: rotate(90deg);
      }
    }
  }
  .toggle-details{
    padding: 0.6rem;
    @include display-flex(row);
  }
  .content{
    margin-block-start: 0.2em;
    padding: 0 0.6rem 0.6rem;
  }
  .icon{
    :global(.fa){
      color: grey;
      font-size: 1.2em;
      margin-inline-end: 0.5em;
    }
  }
</style>
