<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { compact } from 'underscore'
  export let imagesUrls, limit = 1, imageSize = 200

  $: displayedImages = compact(imagesUrls).slice(0, limit)
</script>

<div
  class="images-collage"
  class:single={limit === 1}
>
  {#each displayedImages as imageUrl}
    <img src={imgSrc(imageUrl, imageSize, imageSize)} alt="" />
  {/each}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  // Will have a width and height of 0 by default:
  // this need to be overriden by the parent component
  .images-collage{
    background-color: #dcdcdc;
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
