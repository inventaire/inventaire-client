<script>
  import Spinner from '#general/components/spinner.svelte'
  import { icon, truncateText } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
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
    <div class="image">
      <img src={imgSrc(option.image, 64, 64)} alt="" loading="lazy" />
    </div>
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
  {#await option.promise}
    <Spinner />
  {/await}
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
    img{
      object-fit: cover;
      width: 100%;
      height: 100%;
    }
  }
  .text{
    flex: 1 1 0;
    text-align: initial;
    white-space: pre-wrap;
    line-height: 1rem;
    margin: 0 0.2em;
    padding-inline-start: 0.2em;
  }
  .count{
    color: $grey;
  }
</style>
