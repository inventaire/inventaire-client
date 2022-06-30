<script>
  import { i18n } from '#user/lib/i18n'
  import { isOpenedOutside } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import Link from '#lib/components/link.svelte'

  export let entity,
    size = 300,
    withLink = false

  const { image, uri, label } = entity

  let creditsUrl, creditsText

  if (image.credits) {
    creditsUrl = image.credits.url
    creditsText = image.credits.text
}

  const url = `/entity/${uri}`

  const showLink = e => {
    e.stopPropagation()
    if (!isOpenedOutside(e)) {
      app.navigateAndLoad(url)
      e.preventDefault()
    }
  }

  let altMessage
  if (entity.type === 'edition') {
    altMessage = `${entity.type} cover`
  } else {
    altMessage = `${entity.type} image`
  }
</script>

<div class="entity-image">
  {#if withLink}
    <a
      href={url}
      on:click={showLink}
    >
      <img
        src={imgSrc(image.url, size)}
        alt="{i18n(altMessage)} - {label}"
      >
    </a>
  {:else}
    <img
      src={imgSrc(image.url, size)}
      alt="{i18n(altMessage)} - {label}"
    >
  {/if}
  {#if creditsText}
    <p
      class="photo-credits"
      style="max-width: {size};"
    >
      {i18n('photo credits:')}
      <Link
        url={creditsUrl}
        text={creditsText}
      />
    </p>
  {/if}
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .photo-credits{
    margin: 0 auto;
    font-size: 0.8em;
    max-width: 20em;
    @include shy(0.4);
  }
</style>
