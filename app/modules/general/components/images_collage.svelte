<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  export let imagesUrls, limit = 1

  const imageSize = 200

  $: displayedImages = imagesUrls.slice(0, limit)
</script>

<div
  class="images-collage"
  class:single={displayedImages.length === 1}
  class:duo={displayedImages.length === 2}
  class:square={displayedImages.length >= 3}
  >
  {#each displayedImages as imageUrl}
    <div
      class="image-container"
      style:background-image={`url(${imgSrc(imageUrl, imageSize, imageSize)})`}
    ></div>
  {/each}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  // Will have a width and height of 0 by default:
  // this need to be overriden by the parent component
  .images-collage{
    @include display-flex(row, center, center, wrap);
  }
  .image-container{
    background-size: cover;
    background-position: center center;
  }
  .single{
    .image-container{
      flex: 1 0 100%;
      height: 100%;
    }
  }
  .duo{
    .image-container{
      background-position: top;
      flex: 0 0 100%;
      height: 50%;
    }
  }
  .square{
    .image-container{
      flex: 0 0 50%;
      height: 50%;
    }
  }
</style>
