<script context="module">
  const typeMainProperty = {
    author: 'wdt:P50',
    publisher: 'wdt:P123',
    genre: 'wdt:P136',
    series: 'wdt:P179',
    collection: 'wdt:P195',
    edition: 'wdt:P629',
    translator: 'wdt:P655',
    subject: 'wdt:P921',
  }
</script>
<script>
  import { getContext } from 'svelte'
  import ImagesCollage from '#components/images_collage.svelte'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import { isSubEntitiesType } from '#entities/components/lib/works_browser_helpers'
  import { loadInternalLink } from '#lib/utils'
  import Infobox from './infobox.svelte'

  export let entity,
    relatedEntities,
    showInfobox = true,
    listDisplay = false,
    isUriToDisplay

  let { claims, label, image, images, pathname, serieOrdinal, subtitle, title, type, uri } = entity

  const layoutContext = getContext('layout-context')

  const prop = typeMainProperty[layoutContext]
  const hasOnlyOneClaimValue = prop => claims?.[prop]?.length === 1
  if (prop && hasOnlyOneClaimValue(prop)) {
    claims = omitClaims(claims, [ prop ])
  }
</script>
<div class="entity-list-row">
  <div class="entity-wrapper">
    <div
      class="cover"
      class:hasSubEntities={isSubEntitiesType(type)}
    >
      <a
        href={pathname}
        on:click={loadInternalLink}
        {title}
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
        {#if isUriToDisplay}
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
</div>
<style lang="scss">
  @import "#general/scss/utils";
  .entity-list-row{
    @include display-flex(row, center);
    background-color: white;
    inline-size: 100%;
    margin-block-end: 0.5em;
    padding: 0.5em;
  }
  .entity-wrapper{
    @include display-flex(row, center);
  }
  .entity-title{
    font-size: 1.1rem;
    line-height: 1.2rem;
    margin-block-end: 0.4rem;
    overflow: auto;
    max-height: 10em;
    .uri{
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
      inline-size: 7em;
      block-size: 10em;
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

  /* Small screens */
  @media screen and (max-width: $smaller-screen){
    .entity-list-row{
      flex-wrap: wrap;
    }
    .entity-info-line{
      margin: 0.5em 0.5em 0.5em 0;
    }
  }
</style>
