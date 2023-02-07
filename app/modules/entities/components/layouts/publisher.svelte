<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '../lib/entities'
  import { byPublicationDate } from '#entities/lib/entities'
  import BaseLayout from './base_layout.svelte'
  import Infobox from './infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import EntityTitle from './entity_title.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import MissingEntitiesMenu from '#entities/components/layouts/missing_entities_menu.svelte'
  import { getEntityMetadata } from '#entities/lib/document_metadata'

  export let entity, standalone, flash

  const { uri } = entity
  app.navigate(`/entity/${uri}`, { metadata: getEntityMetadata(entity) })

  let sections
  const waitingForSubEntities = getSubEntitiesSections({ entity, sortFn: byPublicationDate })
    .then(res => sections = res)
    .catch(err => flash = err)

  setContext('layout-context', 'publisher')
  setContext('search-filter-claim', `wdt:P123=${uri}`)
  // TODO: index editions
  setContext('search-filter-types', [ 'collections' ])
  const createButtons = [
    { type: 'collection', claims: { 'wdt:P123': [ uri ] } },
    { type: 'edition', claims: { 'wdt:P123': [ uri ] } },
  ]
</script>

<BaseLayout
  bind:entity
  {standalone}
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="work-section">
        <EntityTitle {entity} {standalone} />
        <Infobox
          claims={entity.claims}
          entityType={entity.type}
        />
        <Summary {entity} />
      </div>
      <div class="publications">
        {#await waitingForSubEntities}
          <Spinner center={true} />
        {:then}
          <WorksBrowser {sections} />
        {/await}
      </div>
    </div>
    <MissingEntitiesMenu
      waiting={waitingForSubEntities}
      questionText="A collection or an edition from this publisher is missing in the common database?"
      {createButtons}
    />
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
  }
</style>
