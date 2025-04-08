<script lang="ts">
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getListingPathname, getElementsImages } from '#listings/lib/listings'
  import { i18n } from '#user/lib/i18n'
  import { getUserById } from '#users/users_data'

  export let listing

  const { _id, name, creator } = listing
  const elements = listing.elements || []
  const imagesLimit = 6

  const pathname = getListingPathname(_id)

  const waitingForImages = getElementsImages(elements, imagesLimit)

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
      {#await waitingForImages then imagesUrls}
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
  @use "#general/scss/utils";
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
