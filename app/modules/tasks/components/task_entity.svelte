<script lang="ts">
  import { isNonEmptyPlainObject } from '#app/lib/boolean_tests'
  import Flash from '#app/lib/components/flash.svelte'
  import EntityImage from '#entities/components/entity_image.svelte'
  import EntityTitle from '#entities/components/layouts/entity_title.svelte'
  import Infobox from '#entities/components/layouts/infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { omitClaims } from '#entities/components/lib/work_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import { getRelatedEntitiesSections } from '#tasks/components/lib/tasks_helpers'
  import RelatedEntitiesSection from './related_entities_section.svelte'

  export let entity
  export let matchedTitles
  const hasLinkTitle = true

  let sections, flash

  const waitingForRelatedEntities = getRelatedEntitiesSections({ entity })
    .then(res => sections = res)
    .catch(err => flash = err)

  const typeMainProperty = {
    work: 'wdt:P50',
    collection: 'wdt:P123',
  }

  const mainProp = typeMainProperty[entity?.type]
  const claims = omitClaims(entity?.claims, [ mainProp ])
</script>

{#if entity}
  <div class="task-entity">
    <div class="title-row">
      <EntityTitle
        {entity}
        {hasLinkTitle}
        hasSourceLogo={true}
      />
      {#if isNonEmptyPlainObject(entity.image)}
        <div class="entity-image-wrapper">
          <EntityImage
            {entity}
            size={96}
            noImageCredits={true}
          />
        </div>
      {/if}
    </div>
    <div class="entity-section">
      <div class="infobox-wrapper">
        <Infobox
          {claims}
          omittedProperties={[ 'wdt:P123', 'wdt:P629' ]}
          entityType={entity.type}
        />
      </div>
      <div class="summary-wrapper">
        <Summary {entity} />
      </div>
    </div>
    <div class="related-entities-section">
      {#await waitingForRelatedEntities}
        <p class="loading"><Spinner /></p>
      {:then}
        {#each sections as section}
          <RelatedEntitiesSection
            {section}
            {matchedTitles}
          />
        {/each}
      {/await}
    </div>
  </div>

  <Flash bind:state={flash} />
{/if}

<style lang="scss">
  @import "#general/scss/utils";
  .task-entity{
    padding: 0 1em;
    // Leave some room for TaskControls
    // aka: when scrolling, make the last related entity visible
    margin-block-end: 8em;
  }
  .entity-section{
    @include display-flex(row, flex-start, flex-start);
  }
  .title-row{
    @include display-flex(column, center);
    margin-block-end: 1em;
  }
  .entity-image-wrapper{
    margin-inline-start: 1em;
  }
  .infobox-wrapper, .summary-wrapper{
    flex: 1 0 0;
  }
  .summary-wrapper{
    margin-inline-start: 0.3em;
  }
  .related-entities-section{
    :global(ul){
      max-height: 80vh;
      overflow: auto;
    }
  }
  /* Small screens */
  @media screen and (width < $small-screen){
    .entity-section{
      flex-direction: column;
    }
    .summary-wrapper{
      margin-inline-start: 0;
      margin-block-start: 1em;
    }
  }
</style>
