<script lang="ts">
  import { imgSrc } from '#app/lib/handlebars_helpers/images'
  import { getColorSquareDataUri, getColorHexCodeFromModelId } from '#app/lib/images'

  export let shelf
  const shelfColorDataUrl = getColorSquareDataUri(shelf.color || getColorHexCodeFromModelId(shelf._id))
</script>

<div class="shelf-info">
  <img
    class="shelf-picture"
    src={imgSrc(shelfColorDataUrl)}
    alt={shelf.name}
  />
  <div class="shelf-text">
    <p class="name">{shelf.name}</p>
    <p class="description">{shelf.description}</p>
  </div>
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .shelf-picture{
    flex: 0 0 auto;
    width: 48px;
    @include radius;
  }
  .shelf-info{
    @include display-flex(row, center, flex-start);
  }
  .shelf-text{
    margin: 0 0.5em;
  }
  p{
    line-height: 1.2rem;
  }
  .description{
    color: $label-grey;
    max-height: 1.2em;
    overflow: hidden;
  }
</style>
