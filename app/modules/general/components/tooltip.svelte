<script>
  export let light = false
</script>

<div class="has-tooltip" tabindex="0">
  <slot name="primary" />

  <div class="tooltip-outer">
    <div class="tooltip-wrapper" role="tooltip">
      <div
        class="tooltip-content"
        class:light={light}
        >
        <slot name="tooltip-content" />
      </div>
    </div>
  </div>
</div>

<style lang="scss">
  @import '#general/scss/utils';

  // Adapted from https://www.cssportal.com/css-tooltip-generator/
  $tooltip-bg-color: $dark-grey;
  $tooltip-light-bg-color: white;
  $spike-size: 0.5rem;

  .has-tooltip{
    display: inline-block;
    position: relative;
    &:not(:hover):not(:focus){
      .tooltip-wrapper{
        display: none;
      }
    }
  }
  .tooltip-outer{
    position: absolute;
    bottom: 100%;
    left: 50%;
    transform: translateX(-50%);
    z-index: 1;
    padding-bottom: $spike-size;
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
    &:after{
      content: '';
      position: absolute;
      top: 100%;
      left: 50%;
      margin-left: -$spike-size;
      width: 0;
      height: 0;
      border-top: $spike-size solid $tooltip-bg-color;
      border-right: $spike-size solid transparent;
      border-left: $spike-size solid transparent;
    }

    &.light{
      color: $dark-grey;
      background-color: white;
      :global(a){
        @include link-dark;
      }
      &:after{
        border-top: $spike-size solid $tooltip-light-bg-color;
      }
    }
    &:not(.light){
      :global(a){
        @include link-light;
      }
    }
  }
</style>
