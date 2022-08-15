<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntitiesSections } from '../lib/entities'
  import { byPublicationDate } from '#entities/lib/entities'
  import { removeAuthorsClaims } from '#entities/components/lib/work_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import WikipediaExtract from './wikipedia_extract.svelte'
  import EntityTitle from './entity_title.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import { extendedAuthorsKeys } from '#entities/lib/show_all_authors_preview_lists'

  export let entity, standalone, flash

  const { uri } = entity

  let sections
  const waitingForSubEntities = getSubEntitiesSections({ entity, sortFn: byPublicationDate })
    .then(res => sections = res)
    .catch(err => flash = err)

  setContext('layout-context', 'author')
  const authorProperties = Object.keys(extendedAuthorsKeys)
  setContext('search-filter-claim', authorProperties.map(property => `${property}=${uri}`).join('|'))

  $: app.navigate(`/entity/${uri}`)
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
        <WikipediaExtract {entity} />
        <Infobox
          claims={removeAuthorsClaims(entity.claims)}
          entityType={entity.type}
        />
      </div>
      <div class="author-works">
        {#await waitingForSubEntities}
          <Spinner center={true} />
        {:then}
          <WorksBrowser {sections} />
        {/await}
      </div>
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  .entity-layout{
    align-self: stretch;
  }
  .author-works{
    margin-top: 1em;
  }
</style>
