<script lang="ts">
  import { pluck } from 'underscore'
  import { loadInternalLink } from '#app/lib/utils'
  import { getUserById } from '#app/modules/users/users_data'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getEntitiesImagesUrls } from '#entities/lib/entities'
  import { getListingPathname } from '#listings/lib/listings'
  import { i18n } from '#user/lib/i18n'

  export let listing

  const { _id, name, creator } = listing
  const elements = listing.elements || []
  let imagesUrls = []
  const imagesLimit = 6

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
    ;({ username } = await getUserById(creator))
    longName = `${name} - ${i18n('list_created_by', { username })}`
  }

  const waitingForUserdata = getCreator()
</script>

<li>
  <a
    href={pathname}
    title={longName || name}
    on:click={loadInternalLink}
  >
    <div class="collage-wrapper">
      {#await waitingForImages then}
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
      {/await}
    </div>
    <div class="listing-info">
      <span class="name">{name}</span>
    </div>
    <div class="creator-info" aria-label={i18n('list_created_by', { username })}>
      {#await waitingForUserdata then}
        <span class="username">{username}</span>
      {/await}
    </div>
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
  }
  .collage-wrapper{
    height: 10em;
    :global(.images-collage){
      height: 100%;
    }
  }
  .listing-info{
    margin: 0.2em 0;
    min-height: 4em;
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
    inset-block-start: 0.5em;
    inset-inline-end: 0.5em;
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
  @media screen and (width < $smaller-screen){
    li{
      width: 100%;
    }
    a{
      width: 100%;
    }
  }
</style>
