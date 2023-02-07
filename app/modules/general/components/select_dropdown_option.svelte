<script>
  import { icon } from '#lib/handlebars_helpers/icons'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { truncateText } from '#lib/utils'
  export let option, withImage = false, displayCount = true
</script>

<div
  class="inner-select-option"
  class:has-image={withImage}
>
  {#if option.icon}
    {@html icon(option.icon)}
  {/if}
  {#if option.image}
    <div
      class="image"
      style:background-image={option.image ? `url(${imgSrc(option.image, 64, 64)})` : null}
    />
  {/if}
  <span class="text">
    {#if option.image}
      {truncateText(option.text, 30)}
    {:else}
      {truncateText(option.text, 35)}
    {/if}
    {#if displayCount && option.count != null}
      <span class="count">({option.count})</span>
    {/if}
  </span>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  $image-size: 2em;
  .inner-select-option{
    flex: 1;
    @include display-flex(row, center, flex-start);
    &.has-image{
      height: $image-size;
    }
  }
  .image{
    flex: 0 0 $image-size;
    width: $image-size;
    height: $image-size;
    overflow: hidden;
    background-size: cover;
    background-position: center center;
  }
  .text{
    flex: 1 1 0;
    text-align: initial;
    white-space: pre-wrap;
    line-height: 1rem;
    margin: 0 0.2em;
    padding-left: 0.2em;
  }
  .count{
    color: $grey;
  }
</style>
