<script lang="ts">
  export let light = false
</script>

<div class="has-tooltip">
  <slot name="primary" />

  <div class="tooltip-outer">
    <div class="tooltip-wrapper" role="tooltip">
      <div
        class="tooltip-content"
        class:light
      >
        <slot name="tooltip-content" />
      </div>
    </div>
  </div>
</div>

<style lang="scss">
  @use "#general/scss/utils";

  // Adapted from https://www.cssportal.com/css-tooltip-generator/
  $tooltip-bg-color: $dark-grey;
  $tooltip-light-bg-color: white;
  $spike-size: 0.5rem;

  .has-tooltip{
    display: inline-block;
    position: relative;
    &:not(:hover, :focus){
      .tooltip-wrapper{
        display: none;
      }
    }
  }
  .tooltip-outer{
    position: absolute;
    inset-block-end: 100%;
    inset-inline-start: 50%;
    transform: translateX(-50%);
    z-index: 1;
    padding-block-end: $spike-size;
  }
  .tooltip-wrapper{
    position: relative;
    white-space: nowrap;
    cursor: default;
  }

  // The actual tooltip box shape and what's inside
  .tooltip-content{
    @include shy(0.95);
    padding: 1em;
    margin: 0 auto;
    min-width: 3em;
    text-align: center;
    color: white;
    background-color: $tooltip-bg-color;
    @include radius;

    :global(a){
      @include link-light;
    }

    // Arrow
    &::after{
      content: "";
      position: absolute;
      inset-block-start: 100%;
      inset-inline-start: 50%;
      margin-inline-start: -$spike-size;
      width: 0;
      height: 0;
      border-block-start: $spike-size solid $tooltip-bg-color;
      border-inline-end: $spike-size solid transparent;
      border-inline-start: $spike-size solid transparent;
    }

    &.light{
      color: $dark-grey;
      background-color: white;
      :global(a){
        @include link-dark;
      }
      &::after{
        border-block-start: $spike-size solid $tooltip-light-bg-color;
      }
    }
    &:not(.light){
      :global(a){
        @include link-light;
      }
    }
  }
</style>
