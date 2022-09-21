<script>
  import { i18n } from '#user/lib/i18n'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntitiesImagesUrls } from '#entities/lib/entities'
  import { getListingPathname } from '#listings/lib/listings'
  import { loadInternalLink } from '#lib/utils'
  import { pluck } from 'underscore'

  export let listing, onUserLayout

  const { _id, name, creator } = listing
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

  let username, userPicture, longName
  const getCreator = async () => {
    ;({ username, picture: userPicture } = await app.request('get:user:data', creator))
    longName = `${name} - ${i18n('list_created_by', { username })}`
  }

  let waitingForUserdata
  if (!onUserLayout) waitingForUserdata = getCreator()
</script>

<li>
  <a
    href={pathname}
    title={longName || name}
    on:click={loadInternalLink}
    class:on-user-layout={onUserLayout}
  >
    {#await waitingForImages then}
      <div class="collage-wrapper">
        <ImagesCollage
          imagesUrls={imagesUrls}
          limit={6}
        />
        <span
          class="counter"
          title={i18n('list_element_count', { smart_count: elements.length })}
        >
          {elements.length}
        </span>
      </div>
    {/await}
    <div class="listing-info">
      <span class="name">{name}</span>
    </div>
    {#if !onUserLayout}
      <div class="creator-info" aria-label={i18n('list_created_by', { username })}>
        {#await waitingForUserdata then}
          <span class="username">{username}</span>
        {/await}
      </div>
    {/if}
  </a>
</li>

<style lang="scss">
  @import '#general/scss/utils';
  li{
    margin: 0.2em;
  }
  a{
    @include display-flex(column, stretch, flex-start);
    @include bg-hover($light-grey);
    @include radius;
    width: 19em;
    padding: 0.3em;
    position: relative;
    min-height: 12em;
  }
  .collage-wrapper{
    flex: 1 0 5em;
    :global(.images-collage){
      height: 100%;
    }
  }
  .listing-info{
    margin: 0.2em 0;
    flex: 0 0 3.5em;
    overflow: hidden;
    @include display-flex(row, center, space-between);
  }
  .name{
    font-size: 1.2rem;
    font-weight: bold;
    @include serif;
    line-height: 1.4rem;
    overflow: hidden;
  }
  .counter{
    position: absolute;
    top: 0.5em;
    right: 0.5em;
    color: $grey;
    padding: 0.2em;
    line-height: 1rem;
    min-width: 1.2em;
    text-align: center;
    font-weight: bold;
    background-color: white;
    @include radius;
  }
  .creator-info{
    padding: 0 0.5em;
    @include display-flex(row, center, flex-end);
  }
  .username{
    font-weight: normal;
    @include sans-serif;
  }
</style>
