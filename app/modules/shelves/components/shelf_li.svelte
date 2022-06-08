<script>
  import { i18n, I18n } from '#user/lib/i18n'
  import { icon } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import { getColorSquareDataUri } from '#lib/images'

  export let shelf

  const { name, description, pathname, color, listing } = shelf
  const picture = getColorSquareDataUri(color)
  // TO FINISH AFTER THE VISIBILITY IS IMPLEMENTED
  const listingLabel = listing
</script>

<li>
  <a
    href="{pathname}"
    class="selectShelf shelf-row"
    title="{name}{description ? ` - ${description}` : ''}"
  >
    <div class="shelf-left">
      <div class="picture" style="background-image: url({imgSrc(picture, 48)})"></div>
      <div class="shelf-text">
        <div class="name">{name}</div>
        <div class="description">{description}</div>
      </div>
    </div>
    <div class="shelf-right">
      <span class="listing {listing}" title="{i18n(listingLabel)}">{@html icon(shelf.icon)}</span>
    </div>
  </a>
</li>
