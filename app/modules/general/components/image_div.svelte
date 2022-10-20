<script>
  import { imgSrc } from '#lib/handlebars_helpers/images'
  export let url, size = 200
</script>

<div
  class="image-div"
  style:background-image={`url(${imgSrc(url, size, size)})`}
  style:width={size}
></div>

<style lang="scss">
  @import '#general/scss/utils';
  .image-div{
    background-size: cover;
    background-position: center center;
  }
</style>
