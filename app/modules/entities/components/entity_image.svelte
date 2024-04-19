<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import ImageDiv from '#components/image_div.svelte'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { i18n } from '#user/lib/i18n'

  export let entity: SerializedEntity
  export let size = 300
  export let withLink = false
  export let noImageCredits = false

  const { image, uri } = entity
  const { url } = image
  let creditsUrl, creditsText

  if ('credits' in image) {
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
  .photo-credits{
    margin: 0;
    font-size: 0.8em;
    max-inline-size: 20em;
    @include shy(0.4);
  }
</style>
