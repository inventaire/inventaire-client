<script>
  import { i18n } from '#user/lib/i18n'
  import Link from '#lib/components/link.svelte'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'

  export let listing
  const { _id } = listing
  let imagesUrls

  const onClick = listingId => () => {
    app.navigateAndLoad(`/lists/${listingId}`)
  }

  const getElementsImages = async () => {
    const allElementsUris = listing.elements.map(_.property('uri'))
    // TODO: make it fast by paginating entities: check if they hava enough images for the collage, and fetch more if not.
    const elementsUris = allElementsUris.slice(0, 15)
    const { entities } = await getEntitiesAttributesByUris({
      uris: elementsUris,
      attributes: [ 'image' ]
    })
    imagesUrls = _.compact(Object.values(entities).map(entity => entity.image.url))
  }

  const waitingForImages = getElementsImages()
</script>
<div
  class="listing-li"
  on:click={onClick(_id)}
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
    <Link
      url={`/lists/${_id}`}
      text={listing.name}
    />
    <p class="listing-counter">
      {i18n('list_element_count', { count: listing.elements.length })}
    </p>
  </span>
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .listing-li{
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
