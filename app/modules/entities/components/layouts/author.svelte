<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '../lib/entities'
  import { byPublicationDate } from '#entities/lib/entities'
  import { removeAuthorsClaims } from '#entities/components/lib/work_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import EntityTitle from './entity_title.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import { extendedAuthorsKeys } from '#entities/lib/show_all_authors_preview_lists'
  import MissingEntitiesMenu from '#entities/components/layouts/missing_entities_menu.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'

  export let entity, standalone, flash

  const { uri } = entity
  app.navigate(`/entity/${uri}`)

  let sections
  const waitingForSubEntities = getSubEntitiesSections({ entity, sortFn: byPublicationDate })
    .then(res => sections = res)
    .catch(err => flash = err)

  setContext('layout-context', 'author')
  const authorProperties = Object.keys(extendedAuthorsKeys)
  setContext('search-filter-claim', authorProperties.map(property => `${property}=${uri}`).join('|'))
  setContext('search-filter-types', [ 'series', 'works' ])
  const createButtons = [
    { type: 'serie', claims: { 'wdt:P50': [ uri ] } },
    { type: 'work', claims: { 'wdt:P50': [ uri ] } },
  ]
</script>

<BaseLayout
  bind:entity={entity}
  {standalone}
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="work-section">
        <EntityTitle {entity} {standalone}/>
        <AuthorsInfo claims={entity.claims} />
        <div class="infobox-and-summary">
          <Infobox
            claims={removeAuthorsClaims(entity.claims)}
            entityType={entity.type}
          />
          <Summary {entity} />
        </div>
      </div>
      <div class="author-works">
        {#await waitingForSubEntities}
          <Spinner center={true} />
        {:then}
          <WorksBrowser {sections} />
        {/await}
      </div>
    </div>
    <MissingEntitiesMenu
      waiting={waitingForSubEntities}
      questionText={'A series or a work by this author is missing in the common database?'}
      {createButtons}
    />
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
  }
  .author-works{
    margin-top: 1em;
  }
  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .infobox-and-summary{
      @include display-flex(row, baseline);
      :global(.claims-infobox-wrapper), :global(.summary-wrapper){
        width: 50%;
      }
    }
  }
</style>
