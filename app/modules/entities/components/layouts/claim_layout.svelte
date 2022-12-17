<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '../lib/entities'
  import { byPublicationDate } from '#entities/lib/entities'
  import BaseLayout from './base_layout.svelte'
  import EntityImage from '../entity_image.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import EntityTitle from './entity_title.svelte'
  import RelativeEntitiesList from './relative_entities_list.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import { getEntityMetadata } from '#entities/lib/document_metadata'
  import { getRelativeEntitiesListLabel, getRelativeEntitiesProperties } from '#entities/components/lib/relative_entities_helpers.js'
  import { isStandaloneEntityType } from '#entities/lib/types/entities_types'

  export let entity, property
  let flash

  const { uri, type } = entity
  app.navigate(`/entity/${property}-${uri}`, { metadata: getEntityMetadata(entity) })
  let sections

  const waitingForReverseEntities = getSubEntitiesSections({ entity, sortFn: byPublicationDate, property })
    .then(res => {
      sections = res
    })
    .catch(err => flash = err)

  setContext('layout-context', 'claim')
  setContext('search-filter-claim', `${property}=${uri}`)
  setContext('search-filter-types', null)
</script>

<BaseLayout
  bind:entity={entity}
  bind:flash
  showEntityEditButtons={false}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <EntityTitle
        {entity}
        standalone={!isStandaloneEntityType(type)}
      />
      <div class="description">
        {entity.description}
      </div>
      {#if !isStandaloneEntityType(type)}
        {#if entity.image}
          <div class="entity-image">
            <EntityImage
              entity={entity}
              size={192}
            />
          </div>
        {/if}
        <Summary {entity} />
      {/if}
      <div class="relatives-browser">
        {#await waitingForReverseEntities}
          <Spinner center={true} />
        {:then}
          <WorksBrowser {sections} />
        {/await}
      </div>
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
  .relatives-browser{
    margin-top: 1em;
  }
</style>
