<script lang="ts">
  import { compact } from 'underscore'
  import { imgSrc } from '#lib/handlebars_helpers/images'

  export let imagesUrls, limit = 1, imageSize = 200

  $: displayedImages = compact(imagesUrls).slice(0, limit)
</script>

<div
  class="images-collage"
  class:single={limit === 1}
  class:empty={displayedImages.length === 0}
>
  {#each displayedImages as imageUrl}
    <img src={imgSrc(imageUrl, imageSize, imageSize)} alt="" loading="lazy" />
  {/each}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  // Will have a width and height of 0 by default:
  // this need to be overriden by the parent component
  .images-collage{
    background-color: $image-placeholder-grey;
    @include display-flex(row, center, center);
    overflow: hidden;
    &:not(.single){
      img{
        max-width: 50%;
      }
    }
  }
  img{
    flex: 1 1 auto;
    height: 100%;
    object-fit: cover;
  }
</style>
