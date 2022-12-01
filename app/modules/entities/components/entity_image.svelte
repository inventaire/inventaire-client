<script>
  import { i18n } from '#user/lib/i18n'
  import { loadInternalLink } from '#lib/utils'
  import Link from '#lib/components/link.svelte'
  import ImagesCollage from '#components/images_collage.svelte'

  export let entity,
    size = 300,
    withLink = false,
    noImageCredits

  const { image, uri } = entity
  const { url: imageUrl } = image
  let creditsUrl, creditsText

  if (image.credits) {
    creditsUrl = image.credits.url
    creditsText = image.credits.text
  }

  const url = `/entity/${uri}`
</script>

<div class="entity-image">
  {#if withLink}
    <a
      href={url}
      on:click={loadInternalLink}
    >
      <ImagesCollage
        imagesUrls={[ imageUrl ]}
        imageSize={size}
        limit={1}
      />
    </a>
  {:else}
    <ImagesCollage
      imagesUrls={[ imageUrl ]}
      imageSize={size}
      limit={1}
    />
  {/if}
  {#if creditsText && !noImageCredits}
    <p class="photo-credits" >
      {i18n('photo credits:')}
      <Link
        url={creditsUrl}
        text={creditsText}
      />
    </p>
  {/if}
</div>

<style lang="scss">
  @import "#general/scss/utils";
  .photo-credits{
    margin: 0;
    font-size: 0.8em;
    max-width: 20em;
    @include shy(0.4);
  }
</style>
