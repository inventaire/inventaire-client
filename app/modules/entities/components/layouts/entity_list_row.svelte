<script>
  import { isWorksClaimsContext } from '#entities/components/lib/edition_layout_helpers'
  import { isSubEntitiesType } from '#entities/components/lib/works_browser_helpers'
  import { loadInternalLink } from '#lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import Infobox from './infobox.svelte'
  import { getContext } from 'svelte'

  export let entity,
    relatedEntities,
    showInfobox = true,
    listDisplay = false,
    displayUri

  let { claims, label, uri, title, serieOrdinal, images, image, type, pathname } = entity

  const layoutContext = getContext('layout-context')
  const subtitle = claims['wdt:P1680']
  const infoboxClaims = claims

  if (layoutContext === 'work') {
    delete infoboxClaims['wdt:P629']
    delete infoboxClaims['wdt:P1476']
  }
  if (!isWorksClaimsContext(layoutContext)) {
    delete claims['wd:P50']
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
      title={title}
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
          title={title}
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
    </div>
    {#if displayUri}
      <a
        class="uri"
        href="/entity/{uri}"
        target="_blank"
        rel="noreferrer"
        on:click|stopPropagation
      >
        {uri}
      </a>
    {/if}
    {#if showInfobox}
      <div class="entity-details">
        <Infobox
          {claims}
          bind:relatedEntities={relatedEntities}
          {listDisplay}
          shortlistOnly={true}
          entityType={type}
        />
      </div>
    {/if}
  </div>
</div>
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
    }
    .cover{
      width: 5em;
    }
    .entity-info-line{
      margin: 0.5em 0.5em 0.5em 0;
    }
  }
</style>
