<script lang="ts">
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getElementsImages } from '#listings/lib/listings'
  import { getSerializedUser } from '#users/users_data'

  export let listing

  const { name, creator: creatorId, elements } = listing

  let username
  const imagesLimit = 6

  const getCreator = async () => {
    ;({ username } = await getSerializedUser(creatorId))
  }

  const waitingForUserdata = getCreator()
  const waitingForImages = getElementsImages(elements, imagesLimit)
</script>

<a
  href={`/lists/${listing._id}`}
  class="entity-listing-layout"
  on:click={loadInternalLink}
>
  <div class="listing-name-section">
    <div>{name}</div>
    {#await waitingForUserdata then}
      <span class="username">{username}</span>
    {/await}
  </div>
  {#await waitingForImages then imagesUrls}
    <ImagesCollage
      {imagesUrls}
      limit={imagesLimit}
      imageSize={128}
    />
  {/await}
</a>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-listing-layout{
    @include display-flex(row, center);
    margin: 0 0.5em;
    background-color: $light-grey;
    :global(.images-collage){
      flex: 2;
      block-size: 5em;
    }
    &:not(:last-child){
      margin-block-end: 1em;
    }
    &:hover, &:focus{
      background-color: darken(white, 1%);
    }
  }
  .listing-name-section{
    @include display-flex(column, center);
    padding: 0.5em;
    flex: 3;
  }
  .username{
    align-self: end;
  }
</style>
