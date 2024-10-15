<script lang="ts">
  import Link from '#app/lib/components/link.svelte'
  import { loadInternalLink } from '#app/lib/utils'
  import ImageDiv from '#components/image_div.svelte'
  import Modal from '#components/modal.svelte'
  import type { SerializedEntity } from '#entities/lib/entities'
  import { i18n } from '#user/lib/i18n'

  export let entity: SerializedEntity
  export let size = 300
  export let withLink = false
  export let noImageCredits = false
  export let enlargeInModal = false

  const { image, uri } = entity
  const { url } = image
  let creditsUrl, creditsText
  let showModal = false

  if ('credits' in image) {
    creditsUrl = image.credits.url
    creditsText = image.credits.text
  }
  if (enlargeInModal) {
    withLink = true
  }

  function onImageClick (e) {
    if (enlargeInModal) {
      showModal = true
    } else {
      loadInternalLink(e)
    }
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
      on:click={e => onImageClick(e)}
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
{#if showModal}
  <Modal
    on:closeModal={() => showModal = false}
    closeOnClick={true}
  >
    <ImageDiv
      url={image.url}
      size={1000}
    />
  </Modal>
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .photo-credits{
    margin: 0;
    font-size: 0.8em;
    max-inline-size: 20em;
    @include shy(0.4);
  }
</style>
