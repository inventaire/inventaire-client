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
    showInfobox = true

  let flash

  let { claims, label } = entity

  const subtitle = claims['wdt:P1680']
  const infoboxClaims = claims

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
        text={label}
        dark=true
      />
      {#if subtitle}
        <div class="subtitle">
          {subtitle}
        </div>
      {/if}
    </div>
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
  <!-- keep action button on top (.entity-list flex-direction) to display dropdown  -->
  {#if actionType}
    <svelte:component
      this={buttonActionsComponentsByType[entity.type][actionType]}
      {entity}
      {parentEntity}
      bind:flash={flash}
    />
  {/if}
</div>
<div class="flash">
  <Flash bind:state={flash}/>
</div>
<style lang="scss">
  @import '#general/scss/utils';
  .entity-list{
    @include display-flex(row, flex-start, space-between);
    border-top: 1px solid #ddd;
    padding: 0.3em 0;
    margin-top: 1em;
  }
  .entity-title{
    font-size:1.1em;
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
</style>
