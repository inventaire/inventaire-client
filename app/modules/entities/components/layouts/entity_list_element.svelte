<script>
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'
  import EditionActions from './edition_actions.svelte'
  import MergeAction from './merge_action.svelte'
  import EntityImage from '../entity_image.svelte'
  import getFavoriteLabel from '#entities/lib/get_favorite_label'
  import Infobox from './infobox.svelte'
  import Link from '#lib/components/link.svelte'
  import Flash from '#lib/components/flash.svelte'

  export let entity,
    parentEntity,
    relatedEntities,
    actionType,
    showInfobox = true

  let flash

  let { claims } = entity

  const infoboxClaims = claims
  const entityLabel = getFavoriteLabel(entity)
  if (parentEntity && parentEntity.type === 'work') {
    delete infoboxClaims['wdt:P629']
    delete infoboxClaims['wdt:P1476']
  }

  const buttonActionsComponentsByType = {
    edition: {
      link: EditionActions
    },
    work: {
      merge: MergeAction
    }
  }
</script>
<div class="entity-list">
  {#if isNonEmptyPlainObject(entity.image)}
    <div class="cover">
      <EntityImage
        entity={entity}
        withLink=true
        size={128}
      />
    </div>
  {/if}
  <div class="entity-info-line">
    <div class="entity-title">
      <Link
        url={`/entity/${entity.uri}`}
        text={entityLabel}
        dark=true
      />
    </div>
    {#if showInfobox}
      <div class="entity-details">
        <Infobox
          claims={entity.claims}
          {relatedEntities}
          compactView=true
          entityType={entity.type}
        />
      </div>
    {/if}
  </div>
  <div class="action-button-wrapper">
    {#if actionType}
      <svelte:component
        this={buttonActionsComponentsByType[entity.type][actionType]}
        {entity}
        {parentEntity}
        bind:flash={flash}
      />
    {/if}
  </div>
</div>
<div class="flash">
  <Flash bind:state={flash}/>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .entity-list{
    @include display-flex(row, center, space-between);
    border-top: 1px solid #ddd;
    padding: 0.3em 0;
    margin-top: 1em;
  }
  .entity-title{
    font-size:larger;
  }
  .cover{
    margin-top: 0.5em;
    :global(a img){
      max-height:6em;
      max-width:4em;
    }
  }
  .entity-info-line{
    flex: 1;
    max-width: 30em;
    margin: 0 1em;
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .cover{
      width: 5em
    }
  }

  /*Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .entity-list-info{
      @include display-flex(column);
    }
  }
</style>
