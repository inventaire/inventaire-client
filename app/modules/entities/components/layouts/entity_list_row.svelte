<script>
  import { isSubEntitiesType } from '#entities/components/lib/works_browser_helpers'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import { loadInternalLink } from '#lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import Infobox from './infobox.svelte'
  import { getContext } from 'svelte'

  export let entity,
    relatedEntities,
    showInfobox = true,
    listDisplay = false,
    displayUri

  let { claims, label, image, images, pathname, serieOrdinal, subtitle, title, type, uri } = entity

  const mainPropertyType = {
    author: 'wdt:P50',
    publisher: 'wdt:P123',
    genre: 'wdt:P136',
    series: 'wdt:P179',
    collection: 'wdt:P195',
    edition: 'wdt:P629',
    translator: 'wdt:P655',
    subject: 'wdt:P921',
  }

  const layoutContext = getContext('layout-context')

  const prop = mainPropertyType[layoutContext]
  const hasOnlyOneClaimValue = prop => claims?.[prop]?.length === 1
  if (prop && hasOnlyOneClaimValue(prop)) {
    claims = omitClaims(claims, [ prop ])
  }
</script>
<div class="entity-wrapper">
  <div
    class="cover"
    class:hasSubEntities={isSubEntitiesType(type)}
  >
    <a
      href={pathname}
      on:click={loadInternalLink}
      {title}
      tabindex="-1"
    >
      <ImagesCollage
        imagesUrls={images || [ image.url ]}
        limit={isSubEntitiesType(type) ? 4 : 1}
      />
    </a>
  </div>
  <div class="entity-info-line">
    <div class="entity-title">
      <h3>
        <a
          href={pathname}
          on:click={loadInternalLink}
          class="link"
          {title}
        >
          {#if layoutContext === 'serie' && serieOrdinal}
            {serieOrdinal}.
          {/if}
          {title || label}
        </a>
      </h3>
      {#if subtitle}
        <span class="subtitle">{subtitle}</span>
      {/if}
      {#if displayUri}
        <a
          href={pathname}
          target="_blank"
          rel="noreferrer"
          class="uri"
          on:click|stopPropagation={loadInternalLink}
        >
          {uri}
        </a>
      {/if}
    </div>
    {#if showInfobox}
      <div class="entity-details">
        <Infobox
          {claims}
          bind:relatedEntities
          {listDisplay}
          shortlistOnly={true}
          entityType={type}
        />
      </div>
    {/if}
  </div>
</div>
{#if type === 'work'}
  <slot name="actions" />
{/if}
<style lang="scss">
  @import "#general/scss/utils";
  .entity-wrapper{
    @include display-flex(row, center);
  }
  .entity-title{
    font-size: 1.1rem;
    line-height: 1.2rem;
    margin-bottom: 0.4rem;
    overflow: hidden;
    .uri {
      @include shy;
      font-size: 0.9rem;
    }
  }
  .subtitle{
    line-height: 1rem;
    font-size: 0.9rem;
    color: $label-grey;
  }
  .cover{
    margin: 0 1em 0 0;
    :global(.images-collage){
      width: 7em;
      height: 10em;
    }
  }
  .entity-info-line{
    flex: 1;
    margin: 0 1em;
  }
  h3{
    font-weight: normal;
    font-size: 1.1em;
    margin: 0;
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-wrapper{
      flex-wrap: wrap;
      align-self: center;
    }
    .cover{
      width: 5em;
    }
    .entity-info-line{
      margin: 0.5em 0.5em 0.5em 0;
    }
  }
</style>
