<script>
  import Link from '#lib/components/link.svelte'
  import Flash from '#lib/components/flash.svelte'
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import EditionActions from './edition_actions.svelte'
  import MergeAction from './merge_action.svelte'
  import EntityImage from '../entity_image.svelte'
  import Infobox from './infobox.svelte'

  export let entity,
    parentEntity,
    relatedEntities,
    actionType,
    showInfobox = true,
    noImageCredits,
    displayUri

  let flash

  let { claims, label, uri } = entity

  const subtitle = claims['wdt:P1680']
  const infoboxClaims = claims

  if (parentEntity && parentEntity.type === 'work') {
    delete infoboxClaims['wdt:P629']
    delete infoboxClaims['wdt:P1476']
  }

  const buttonActionsComponents = {}
  if (entity.type === 'edition') {
    buttonActionsComponents.link = EditionActions
  } else {
    buttonActionsComponents.merge = MergeAction
  }
</script>
<div class="entity-wrapper">
  {#if isNonEmptyPlainObject(entity.image)}
    <div class="cover">
      <EntityImage
        entity={entity}
        withLink=true
        size={128}
        {noImageCredits}
      />
    </div>
  {/if}
  <div class="entity-info-line">
    <div class="entity-title">
      <Link
        url={`/entity/${uri}`}
        text={label}
        dark=true
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
{#if actionType}
  <div class="actions-menu">
    <!-- keep action button on top (.entity-list flex-direction) to display dropdown  -->
    {#if actionType}
      <svelte:component
        this={buttonActionsComponents[actionType]}
        {entity}
        {parentEntity}
        bind:flash={flash}
      />
    {/if}
  </div>
  <div class="flash">
    <Flash bind:state={flash}/>
  </div>
{/if}
<style lang="scss">
  @import '#general/scss/utils';
  .entity-wrapper{
    @include display-flex(row);
    margin-bottom: 1em
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
    width: 3.5em;
    :global(a img){
      max-height: 6em;
      max-width: 3.5em;
    }
  }
  .entity-info-line{
    flex: 1;
    max-width: 30em;
    margin: 0 1em;
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-wrapper{
      flex-wrap: wrap;
    }
    .cover{
      width: 5em
    }
  }
</style>
