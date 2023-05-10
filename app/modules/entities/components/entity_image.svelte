<script>
  import { i18n } from '#user/lib/i18n'
  import { loadInternalLink } from '#lib/utils'
  import { imgSrc } from '#lib/handlebars_helpers/images'
  import Link from '#lib/components/link.svelte'

  export let entity,
    size = 300,
    withLink = false,
    noImageCredits

  const { image, uri } = entity

  let creditsUrl, creditsText

  if (image.credits) {
    creditsUrl = image.credits.url
    creditsText = image.credits.text
  }

  const url = `/entity/${uri}`
</script>

{#if image.url}
  <div class="entity-image">
    {#if withLink}
      <a
        href={url}
        on:click={loadInternalLink}
      >
        <img
          src={imgSrc(image.url, size)}
          alt=""
        />
      </a>
    {:else}
      <img
        src={imgSrc(image.url, size)}
        alt=""
      />
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
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .photo-credits{
    margin: 0;
    font-size: 0.8em;
    max-width: 20em;
    @include shy(0.4);
  }
</style>
