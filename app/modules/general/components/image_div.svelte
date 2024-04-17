<script lang="ts">
  import { imgSrc } from '#app/lib/handlebars_helpers/images'

  export let url, size = 200, alt = ''
</script>

<div class="image-div">
  {#if url}
    <img src={imgSrc(url, size, size)} {alt} loading="lazy" />
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  img{
    object-fit: cover;
    width: 100%;
    height: 100%;
  }
</style>
