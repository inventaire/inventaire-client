<script>
  import Link from '#lib/components/link.svelte'
  import EntityImage from '../entity_image.svelte'
  import Infobox from './infobox.svelte'

  export let entity,
    parentEntity,
    relatedEntities,
    showInfobox = true,
    noImageCredits,
    displayUri

  let { claims, label, uri } = entity

  const subtitle = claims['wdt:P1680']
  const infoboxClaims = claims

  if (parentEntity && parentEntity.type === 'work') {
    delete infoboxClaims['wdt:P629']
    delete infoboxClaims['wdt:P1476']
  }
</script>
<div class="entity-wrapper">
  <div class="cover">
    <EntityImage
      entity={entity}
      withLink=true
      size={128}
      {noImageCredits}
    />
  </div>
  <div class="entity-info-line">
    <div class="entity-title">
      <Link
        url={`/entity/${uri}`}
        text={label}
        dark="true"
      />
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
          claims={entity.claims}
          {relatedEntities}
          shortlistOnly={true}
          entityType={entity.type}
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
    max-height: 2.4rem;
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
  /* Small screens */
  @media screen and (max-width: $smaller-screen){
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
