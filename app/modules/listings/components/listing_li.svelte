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
  let imagesUrls = [], imagesLimit = 6

  const pathname = getListingPathname(_id)

  const getElementsImages = async () => {
    const allElementsUris = pluck(elements, 'uri')

    let limit = 0
    const fetchMoreImages = async (offset = 0, amount = 10) => {
      const enoughImages = imagesUrls.length >= imagesLimit
      if (enoughImages) return
      limit = offset + 10
      const elementsUris = allElementsUris.slice(offset, limit)
      const someImagesUrls = await getEntitiesImagesUrls(elementsUris)
      imagesUrls = [ ...imagesUrls, ...someImagesUrls ]
      if (elementsUris.length === 0) return
      offset = amount
      amount += amount
      return fetchMoreImages(offset, amount)
    }
    await fetchMoreImages()
  }

  const waitingForImages = getElementsImages()

  let username, longName
  const getCreator = async () => {
    ;({ username } = await app.request('get:user:data', creator))
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
          {imagesUrls}
          limit={imagesLimit}
        />
        <span
          class="counter"
          title={i18n('number_of_elements_in_the_list', { smart_count: elements.length })}
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
  @import "#general/scss/utils";
  li{
    margin: 0.2em;
  }
  a{
    @include display-flex(column, stretch, flex-start);
    @include bg-hover($light-grey);
    @include radius;
    width: 30em;
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
  /* Smaller screens */
  @media screen and (max-width: $below-smaller-screen){
    li{
      width: 100%;
    }
    a{
      width: 100%;
    }
  }
</style>
