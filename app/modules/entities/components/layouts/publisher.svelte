<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '#entities/components/lib/entities'
  import BaseLayout from './base_layout.svelte'
  import Infobox from './infobox.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import EntityTitle from './entity_title.svelte'
  import HomonymDeduplicates from './deduplicate_homonyms.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import { getEntityMetadata } from '#entities/lib/document_metadata'

  export let entity, standalone
  let flash

  const { uri } = entity
  app.navigate(`/entity/${uri}`, { metadata: getEntityMetadata(entity) })

  let sections
  // server is already sorting byPublicationDate
  const waitingForSubEntities = getSubEntitiesSections({ entity })
    .then(res => sections = res)
    .catch(err => flash = err)

  // TODO: index editions
  // setContext('search-filter-types', null)
  setContext('layout-context', 'publisher')
  setContext('search-filter-claim', `wdt:P123=${uri}`)
</script>

<BaseLayout
  bind:entity
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
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
    :global(.summary.has-summary){
      margin-block-start: 1em;
    }
  }
  .publications{
    margin-block-start: 1em;
  }
</style>
