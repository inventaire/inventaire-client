<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '../lib/entities'
  import { bySerieOrdinal } from '#entities/lib/entities'
  import { omitNonInfoboxClaims } from '#entities/components/lib/work_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import EntityTitle from './entity_title.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import MissingEntitiesMenu from '#entities/components/layouts/missing_entities_menu.svelte'
  import { getEntityMetadata } from '#entities/lib/document_metadata'

  export let entity, standalone
  let flash

  const { uri } = entity
  app.navigate(`/entity/${uri}`, { metadata: getEntityMetadata(entity) })

  let sections
  const waitingForWorks = getSubEntitiesSections({ entity, sortFn: bySerieOrdinal })
    .then(res => sections = res)
    .catch(err => flash = err)

  setContext('layout-context', 'serie')
  setContext('search-filter-claim', `wdt:P179=${uri}|wdt:P361=${uri}`)
  setContext('search-filter-types', [ 'series', 'works' ])
  const createButtons = [
    { type: 'work', claims: { 'wdt:P179': [ uri ] } },
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
        <AuthorsInfo claims={entity.claims} />
        <Infobox
          claims={omitNonInfoboxClaims(entity.claims)}
          entityType={entity.type}
        />
        <Summary {entity} />
      </div>
      <div class="serie-parts">
        {#await waitingForWorks}
          <Spinner center={true} />
        {:then}
          <WorksBrowser {sections} />
        {/await}
      </div>
    </div>
    <MissingEntitiesMenu
      waiting={waitingForWorks}
      questionText="A work of this series is missing in the common database?"
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
  .serie-parts{
    margin-top: 1em;
  }
</style>
