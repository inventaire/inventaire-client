<script lang="ts">
  import app from '#app/app'
  import ImagesCollage from '#components/images_collage.svelte'
  import { getElementsImages } from '#listings/lib/listings'
  import { i18n } from '#user/lib/i18n'

  export let listing, uri

  const { name, creator, elements } = listing

  const { comment } = elements?.find(el => el.uri === uri)

  let username
  const imagesLimit = 6

  const getCreator = async () => {
    ;({ username } = await app.request('get:user:data', creator))
  }

  const waitingForUserdata = getCreator()
  const waitingForImages = getElementsImages(elements, imagesLimit)
</script>

{#if comment}
  <div class="entity-listing-comment-layout">
    <div class="first-row">
      <div class="element-comment">
        {comment}
      </div>
      <div class="creator-info" aria-label={i18n('list_created_by', { username })}>
        {#await waitingForUserdata then}
          <span class="username">{username}</span>
        {/await}
      </div>
    </div>

    <div class="last-row">
      <div class="listing-name">
        {name}
      </div>
      {#await waitingForImages then imagesUrls}
        <ImagesCollage
          {imagesUrls}
          limit={imagesLimit}
          imageSize={128}
        />
      {/await}
    </div>
  </div>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .entity-listing-comment-layout{
    @include display-flex(column);
    width: 100%;
    overflow-y: auto;
  }
  .first-row{
    @include display-flex(row, center, space-between);
  }
  .last-row{
    :global(.images-collage){
      block-size: 7em;
    }
  }
</style>
