<script lang="ts">
  import { setContext } from 'svelte'
  import { debounce } from 'underscore'
  import { onChange } from '#app/lib/svelte/svelte'
  import ActorFollowersSection from '#entities/components/layouts/actor_followers_section.svelte'
  import AddToDotDotDotMenu from '#entities/components/layouts/add_to_dot_dot_dot_menu.svelte'
  import Summary from '#entities/components/layouts/summary.svelte'
  import WorksBrowser from '#entities/components/layouts/works_browser.svelte'
  import { authorsProps } from '#entities/components/lib/claims_helpers'
  import { getSubEntitiesSections } from '#entities/components/lib/entities'
  import { runEntityNavigate } from '#entities/lib/document_metadata'
  import { bySerieOrdinal } from '#entities/lib/entities'
  import Spinner from '#general/components/spinner.svelte'
  import EntityListingsLayout from '#listings/components/entity_listings_layout.svelte'
  import { getRelativeEntitiesListLabel, getRelativeEntitiesProperties } from '../lib/relative_entities_helpers'
  import AuthorsInfo from './authors_info.svelte'
  import BaseLayout from './base_layout.svelte'
  import HomonymDeduplicates from './deduplicate_homonyms.svelte'
  import EntityTitle from './entity_title.svelte'
  import Infobox from './infobox.svelte'
  import RelativeEntitiesList from './relative_entities_list.svelte'

  export let entity

  const { uri, claims, type } = entity
  runEntityNavigate(entity)

  setContext('layout-context', 'serie')
  setContext('search-filter-claim', `wdt:P179=${uri}|wdt:P361=${uri}`)
  setContext('search-filter-types', [ 'series', 'works' ])

  let sections, waitingForWorks, flash
  function getSections () {
    waitingForWorks = getSubEntitiesSections({ entity, sortFn: bySerieOrdinal })
      .then(res => sections = res)
      .catch(err => flash = err)
  }
  const lazyGetSections = debounce(getSections, 100)
  $: if (entity) onChange(entity, lazyGetSections)
</script>

<BaseLayout
  bind:entity
  bind:flash
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="serie-section">
        <EntityTitle {entity} />
        <AuthorsInfo claims={entity.claims} />
        <Infobox
          {claims}
          omittedProperties={authorsProps}
          entityType={entity.type}
        />
        <Summary {entity} />
        <AddToDotDotDotMenu
          {entity}
          {flash}
          align="left"
        />
      </div>
      {#await waitingForWorks}
        <Spinner center={true} />
      {:then}
        <div class="serie-parts">
          <WorksBrowser {sections} />
          <!-- Nest listings within WorksBrowser section to load it at the same time,
          to not have to push it down when WorksBrowser is displayed -->
          <EntityListingsLayout {entity} />
        </div>
      {/await}
    </div>
    <div class="relatives-lists">
      {#each getRelativeEntitiesProperties(type) as property}
        <RelativeEntitiesList
          {entity}
          {property}
          label={getRelativeEntitiesListLabel({ property, entity })}
        />
      {/each}
    </div>
    <ActorFollowersSection uri={entity.uri} />
    <HomonymDeduplicates {entity} />
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  @import "#entities/scss/relatives_lists";
  .entity-layout{
    align-self: stretch;
    @include display-flex(column, stretch);
    :global(.summary.has-summary){
      margin-block-start: 1em;
    }
  }
  .serie-parts{
    margin-block-start: 1em;
  }
  .serie-section{
    :global(.add-to-dot-dot-dot-menu){
      margin-block-start: 1em;
      width: 10em;
    }
  }
  .relatives-lists{
    @include relatives-lists-commons;
  }
</style>
