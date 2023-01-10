<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '#entities/components/lib/entities'
  import { byPublicationDate } from '#entities/lib/entities'
  import BaseLayout from './base_layout.svelte'
  import EntityImage from '../entity_image.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import RelativeEntitiesList from './relative_entities_list.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import { getEntityMetadata } from '#entities/lib/document_metadata'
  import { getRelativeEntitiesListLabel, getRelativeEntitiesProperties } from '#entities/components/lib/relative_entities_helpers.js'
  import { isStandaloneEntityType } from '#entities/lib/types/entities_types'
  import { getSubentitiesTypes } from '#entities/lib/editor/properties_per_type'
  import { isNonEmptyPlainObject } from '#lib/boolean_tests'

  export let entity, property
  let flash

  const { uri, type } = entity
  let { label } = entity
  if (property) label = getRelativeEntitiesListLabel({ property, entity }) || entity.label

  app.navigate(`/entity/${property}-${uri}`, { metadata: getEntityMetadata(entity) })
  let sections

  const waitingForReverseEntities = getSubEntitiesSections({ entity, sortFn: byPublicationDate, property })
    .then(res => {
      sections = res
    })
    .catch(err => flash = err)

  setContext('layout-context', 'claim')
  setContext('search-filter-claim', `${property}=${uri}`)

  const searchTypes = getSubentitiesTypes(property)
  if (searchTypes.length > 0) setContext('search-filter-types', searchTypes)

  const defaultTypeByClaimProperty = {
    'wdt:P135': 'movement',
    'wdt:P136': 'genre',
  }

  const typeLabel = defaultTypeByClaimProperty[property] || 'subject'

  $: entitiesLength = sections?.map(_.property('uris')).flat().length
</script>

<BaseLayout
  bind:entity
  bind:flash
  {typeLabel}
  showEntityEditButtons={false}
>
  <div class="entity-layout" slot="entity">
    <div class="title-row">
      <h2>
        {label}
      </h2>
      {#if sections}
        {#if entitiesLength > 10}
          <span class="counter">
            {entitiesLength}
          </span>
        {/if}
      {/if}
    </div>
    <div class="top-section">
      {#if !isStandaloneEntityType(type)}
        {#if isNonEmptyPlainObject(entity.image)}
          <EntityImage
            {entity}
            size={192}
          />
        {/if}
        <Summary {entity} />
      {/if}
    </div>
    <div class="relatives-browser">
      {#await waitingForReverseEntities}
        <Spinner center={true} />
      {:then}
        <WorksBrowser {sections} />
      {/await}
    </div>
    <div class="relatives-lists">
      {#each getRelativeEntitiesProperties(type, property) as property}
        <RelativeEntitiesList
          {entity}
          {property}
          label={getRelativeEntitiesListLabel({ property, entity })}
        />
      {/each}
    </div>
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
  }
  .top-section{
    @include display-flex(row, center);
    :global(.entity-image){
      flex: 1 0 auto;
      margin-right: 2em;
    }
  }
  .title-row{
    @include display-flex(row, center);
  }
  .counter{
    @include counter-commons;
    background-color: white;
    font-size: 1rem;
    margin-left: 0.5em;
  }
  .relatives-browser{
    margin-top: 1em;
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .top-section{
      display: block;
      :global(.entity-image){
        margin-bottom: 1em;
      }
    }
  }
</style>
