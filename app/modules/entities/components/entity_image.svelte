<script>
  import { i18n } from '#user/lib/i18n'
  import { loadInternalLink } from '#lib/utils'
  import Link from '#lib/components/link.svelte'
  import ImageDiv from '#components/image_div.svelte'

  export let entity,
    size = 300,
    withLink = false,
    noImageCredits

  const { image, uri } = entity
  const { url } = image
  let creditsUrl, creditsText

  if (image.credits) {
    creditsUrl = image.credits.url
    creditsText = image.credits.text
  }

  const entityUrl = `/entity/${uri}`
</script>
<div
  class="entity-image"
  style:max-width="{size}px"
>
  {#if withLink}
    <a
      href={entityUrl}
      on:click={loadInternalLink}
    >
      <ImageDiv {url} {size} />
    </a>
  {:else}
    <ImageDiv {url} {size} />
  {/if}
  {#if creditsText && !noImageCredits}
    <p class="photo-credits">
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
  .entity-image{
    :global(.images-collage){
      block-size: 10em;
    }
  }
  .photo-credits{
    margin: 0;
    font-size: 0.8em;
    max-inline-size: 20em;
    @include shy(0.4);
  }
</style>
