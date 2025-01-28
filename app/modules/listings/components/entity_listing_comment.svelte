<script lang="ts">
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getElementsImages, getListingPathname, getElementPathname } from '#listings/lib/listings'
  import type { EntityUri } from '#server/types/entity'
  import type { ListingWithElements } from '#server/types/listing'
  import { i18n } from '#user/lib/i18n'
  import { getSerializedUser } from '#users/users_data'

  export let listing: ListingWithElements, uri: EntityUri

  const { name, creator: creatorId, elements } = listing

  const { comment, _id: elementId } = elements?.find(el => el.uri === uri)

  const elementPathname = getElementPathname(listing._id, elementId)
  const listingPathname = getListingPathname(listing._id)

  let username
  const imagesLimit = 6

  const getCreator = async () => {
    ;({ username } = await getSerializedUser(creatorId))
  }

  const waitingForUserdata = getCreator()
  const waitingForImages = getElementsImages(elements, imagesLimit)
</script>

{#if comment}
  <a
    href={elementPathname}
    class="entity-listing-comment-layout"
    on:click={loadInternalLink}
  >
    <div class="comment-row">
      <div class="element-comment">
        {comment.slice(0, 150)}
        {#if comment.length > 150}…{/if}
      </div>
      <div class="creator-info" aria-label={i18n('list_created_by', { username })}>
        {#await waitingForUserdata then}
          <span class="username">{username}</span>
        {/await}
      </div>
    </div>

    <a
      href={listingPathname}
      class="listing-row"
      on:click|stopPropagation={loadInternalLink}
    >
      <div class="listing-name-section">
        <div class="listing-name-label">
          {i18n('In list:')}
        </div>
        <div>{name}</div>
      </div>
      {#await waitingForImages then imagesUrls}
        <ImagesCollage
          {imagesUrls}
          limit={imagesLimit}
          imageSize={128}
        />
      {/await}
    </a>
  </a>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .entity-listing-comment-layout{
    @include display-flex(column);
    width: 100%;
    overflow-y: auto;
    padding: 1em;
    background-color: white;
    &:not(:last-child){
      margin-block-end: 1em;
    }
    &:hover, &:focus{
      background-color: darken(white, 1%);
    }
  }
  .element-comment{
    font-size: 1.1em;
    padding-inline-end: 1em;
  }
  .comment-row{
    @include display-flex(column);
    padding-block-end: 0.5em;
  }
  .creator-info{
    align-self: end;
  }
  .listing-name-section{
    padding-block-end: 0.5em;
    padding-inline-end: 0.5em;
    flex: 3;
  }
  .listing-name-label{
    opacity: 0.6;
    padding-block-start: 0.5em;
  }
  .listing-row{
    @include display-flex(row, center);
    padding-inline-start: 1em;
    background-color: $light-grey;
    :global(.images-collage){
      flex: 2;
      block-size: 5em;
    }
    &:hover, &:focus{
      opacity: 0.8;
      @include transition(opacity);
    }
  }
</style>
