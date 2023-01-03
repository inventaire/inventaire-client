<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  export let imagesUrls, limit = 1, imageSize = 200

  $: displayedImages = imagesUrls.slice(0, limit)
</script>

<div
  class="images-collage"
  class:single={limit === 1}
>
  {#each displayedImages as imageUrl}
    <div
      class="image-container"
      style:background-image={`url(${imgSrc(imageUrl, imageSize, imageSize)})`}
    />
  {/each}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  // Will have a width and height of 0 by default:
  // this need to be overriden by the parent component
  .images-collage{
    background-color: #dcdcdc;
    @include display-flex(row, center, center, wrap);
    overflow: hidden;
    &:not(.single){
      .image-container{
        max-width: 50%;
      }
    }
  }
  .image-container{
    background-size: cover;
    background-position: center center;
    flex: 1 1 auto;
    height: 100%;
  }
</style>
