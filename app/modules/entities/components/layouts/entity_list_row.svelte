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
<script lang="ts">
  import { getContext } from 'svelte'
  import { without, flatten } from 'underscore'
  import { loadInternalLink } from '#app/lib/utils'
  import ImagesCollage from '#components/images_collage.svelte'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import { isSubEntitiesType } from '#entities/components/lib/works_browser_helpers'
  import { getWorkAuthorsUris, type SerializedEntity } from '#entities/lib/entities'
  import type { ExtendedEntityType, EntityUri } from '#server/types/entity'
  import ClaimInfobox from './claim_infobox.svelte'
  import Infobox from './infobox.svelte'

  export let entity: SerializedEntity
  export let listDisplay = false
  export let isUriToDisplay = false
  export let parentEntity: SerializedEntity = {}
  export let relatedEntities: SerializedEntity[]

  const { claims, label, image, images, pathname, serieOrdinal, subtitle, title, type, uri } = entity
  const { type: parentEntityType, uri: parentUri }: { parentEntityType: ExtendedEntityType, parentUri: EntityUri } = parentEntity
  let singleValueClaims

  const extendedAuthorsUris = flatten(getWorkAuthorsUris(entity))
  const authorsUrisWithoutParentUri = without(extendedAuthorsUris, parentUri)
  const layoutContext = getContext('layout-context')

  const prop = typeMainProperty[layoutContext]
  const hasOnlyOneClaimValue = prop => claims?.[prop]?.includes(parentUri)
  if (prop && hasOnlyOneClaimValue(prop)) {
    singleValueClaims = omitClaims(claims, [ prop ])
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
      {#if parentEntityType === 'human' && (type === 'work' || type === 'serie')}
        <ClaimInfobox
          values={authorsUrisWithoutParentUri}
          prop="wdt:P50"
          entitiesByUris={relatedEntities}
          customLabel="coauthors"
        />
      {/if}
      <div class="entity-details">
        <Infobox
          claims={singleValueClaims}
          {relatedEntities}
          {listDisplay}
          shortlistOnly={true}
          entityType={type}
        />
      </div>
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

  /* Smaller screens */
  @media screen and (width < $smaller-screen){
    .entity-list-row{
      flex-wrap: wrap;
    }
    .entity-info-line{
      margin: 0.5em 0.5em 0.5em 0;
    }
  }
</style>
