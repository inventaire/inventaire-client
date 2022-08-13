<script>
  import Spinner from '#general/components/spinner.svelte'
  import { getSubEntities } from '../lib/entities'
  import { bySerieOrdinal, serializeEntity } from '#entities/lib/entities'
  import { removeAuthorsClaims } from '#entities/components/lib/work_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import WikipediaExtract from './wikipedia_extract.svelte'
  import EntityTitle from './entity_title.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { setContext } from 'svelte'
  import { addWorksImages } from '#entities/lib/types/work_alt'

  export let entity, standalone, flash

  const { uri } = entity

  let serieParts
  const waitingForWorks = getSubEntities('serie', uri)
    .then(async res => {
      serieParts = res.map(serializeEntity).sort(bySerieOrdinal)
      await addWorksImages(serieParts)
    })
    .catch(err => flash = err)

  setContext('layout-context', 'serie')
  setContext('search-filter-claim', `wdt:P179=${uri}`)

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
      <div class="serie-parts">
        {#await waitingForWorks}
          <Spinner center={true} />
        {:then}
          <WorksBrowser works={serieParts} />
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
  .serie-parts{
    margin-top: 1em;
  }
</style>
