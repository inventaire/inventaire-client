<script>
  import { i18n } from '#user/lib/i18n'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntitiesImagesUrls } from '#entities/lib/entities'
  import { getListingPathname } from '#listings/lib/listings'
  import { loadInternalLink } from '#lib/utils'
  import { pluck } from 'underscore'

  export let listing
  const { _id } = listing
  let elements = listing.elements || []
  let imagesUrls

  const pathname = getListingPathname(_id)

  const getElementsImages = async () => {
    const allElementsUris = pluck(elements, 'uri')
    // TODO: make it fast by paginating entities: check if they have enough images for the collage, and fetch more if not.
    const elementsUris = allElementsUris.slice(0, 10)
    imagesUrls = await getEntitiesImagesUrls(elementsUris)
  }

  const waitingForImages = getElementsImages()
</script>

<li>
  <a
    href={pathname}
    on:click={loadInternalLink}
  >
    {#await waitingForImages then}
      <div class="collage-wrapper">
        <ImagesCollage
          imagesUrls={imagesUrls}
          limit={6}
        />
      </div>
    {/await}
    <span class="info">
      {listing.name}
      <p class="listing-counter">
        {i18n('list_element_count', { count: elements.length })}
      </p>
    </span>
  </a>
</li>

<style lang="scss">
  @import '#general/scss/utils';
  a{
    @include display-flex(column, flex-start, flex-start, wrap);
    @include bg-hover($light-grey);
    @include radius;
    display: block;
    width: 19em;
    min-height: 11em;
    padding: 0.3em;
    margin: 0.2em;
    cursor: pointer;
  }
  .info{
    max-height: 3.5rem;
    overflow: hidden;
  }
  .listing-counter{
    color: $grey;
  }

  .collage-wrapper{
    margin-bottom: 0.3em;
    :global(.images-collage){
      width: 100%;
      height: 5em;
    }
  }
</style>
