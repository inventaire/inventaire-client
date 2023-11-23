<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n } from '#user/lib/i18n'
  import { getSubEntities } from '../lib/entities'
  import { getEntitiesAttributesByUris, byPopularity, getAndAssignPopularity } from '#entities/lib/entities'
  import { getPublishersUrisFromEditions, omitNonInfoboxClaims } from '#entities/components/lib/work_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import Ebooks from './ebooks.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionsList from './editions_list.svelte'
  import EntityListingsLayout from '#listings/components/entity_listings_layout.svelte'
  import EntityTitle from './entity_title.svelte'
  import WorkActions from './work_actions.svelte'
  import HomonymDeduplicates from './deduplicate_homonyms.svelte'
  import RelativeEntitiesList from '#entities/components/layouts/relative_entities_list.svelte'
  import { setContext, tick } from 'svelte'
  import { writable } from 'svelte/store'
  import Summary from '#entities/components/layouts/summary.svelte'
  import { scrollToElement } from '#lib/screen'
  import { getEntityMetadata } from '#entities/lib/document_metadata'
  import { getRelativeEntitiesListLabel, getRelativeEntitiesProperties } from '#entities/components/lib/relative_entities_helpers.js'
  import Flash from '#lib/components/flash.svelte'

  export let entity, standalone

  let showMap, itemsListsWrapperEl, mapWrapperEl, flash

  const { uri, type } = entity
  let editionsUris
  let editions = []
  let initialEditions = []
  const userLang = app.user.lang
  let publishersByUris
  let allItems
  let itemsByEditions = {}
  let waitingForItems

  setContext('work-layout:filters-store', writable({}))

  const getEditionsWithPublishers = async () => {
    initialEditions = await getSubEntities('work', uri)
    const publishersUris = getPublishersUrisFromEditions(initialEditions)
    const { entities } = await getEntitiesAttributesByUris({
      uris: publishersUris,
      // type is necessary to generate publisher URI link without "wdt:P921-" prefix
      attributes: [ 'info', 'labels' ],
      lang: userLang
    })
    publishersByUris = entities
    await getAndAssignPopularity({ entities: initialEditions })
    editions = initialEditions.sort(byPopularity)
  }

  let waitingForEditions = getEditionsWithPublishers().catch(err => flash = err)

  async function showMapAndScrollToMap () {
    showMap = true
    await tick()
    scrollToElement(mapWrapperEl, { marginTop: 10, waitForRoomToScroll: false })
  }

  const scrollToItemsList = () => {
    scrollToElement(itemsListsWrapperEl, { marginTop: 10, waitForRoomToScroll: false })
  }

  $: claims = entity.claims
  $: infoboxClaims = omitNonInfoboxClaims(entity.claims)
  $: app.navigate(`/entity/${uri}`, { metadata: getEntityMetadata(entity) })
  $: if (isNonEmptyArray(editions)) {
    editionsUris = editions.map(_.property('uri'))
  }
  $: someEditions = editions && isNonEmptyArray(editions)
  $: hasSomeInitialEditions = initialEditions && isNonEmptyArray(initialEditions)
</script>

<BaseLayout bind:entity>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="work-section">
        <Flash state={flash} />
        <EntityTitle {entity} {standalone} />
        <AuthorsInfo {claims}
        />
        <Infobox
          claims={infoboxClaims}
          entityType={entity.type}
        />
        <Ebooks
          {entity}
          {userLang}
        />
        <Summary {entity} />
        <WorkActions
          {entity}
          {someEditions}
          {editions}
          bind:allItems
          on:showMapAndScrollToMap={showMapAndScrollToMap}
          on:scrollToItemsList={scrollToItemsList}
        />
      </div>
      <div
        class="editions-section-wrapper"
        class:no-edition={!hasSomeInitialEditions}
      >
        {#await waitingForEditions}
          <div class="loading-wrapper">
            <p class="loading">{i18n('Looking for editions…')}
              <Spinner />
            </p>
          </div>
        {:then}
          <EditionsList
            {hasSomeInitialEditions}
            {someEditions}
            {publishersByUris}
            parentEntity={entity}
            {initialEditions}
            bind:editions
            bind:itemsByEditions
            {waitingForItems}
          />
        {/await}
      </div>
    </div>
    {#await waitingForEditions then}
      {#if someEditions}
        <div class="items-lists-section">
          <ItemsLists
            {editionsUris}
            bind:showMap
            bind:allItems
            bind:itemsByEditions
            bind:waitingForItems
            bind:mapWrapperEl
            bind:itemsListsWrapperEl
            on:showMapAndScrollToMap={showMapAndScrollToMap}
          />
        </div>
      {/if}
    {/await}
    <EntityListingsLayout {entity}
    />
    <div class="relatives-lists">
      {#each getRelativeEntitiesProperties(type) as property}
        <RelativeEntitiesList
          {entity}
          {property}
          label={getRelativeEntitiesListLabel({ property, entity })}
        />
      {/each}
    </div>
    <HomonymDeduplicates {entity}
    />
  </div>
</BaseLayout>

<style lang="scss">
  @import "#general/scss/utils";
  @import "#entities/scss/relatives_lists";
  .entity-layout{
    @include display-flex(column, center);
    inline-size: 100%;
  }
  .no-edition{
    flex: none;
    inline-size: 15em;
  }
  .top-section{
    @include display-flex(row, flex-start, center);
    inline-size: 100%;
  }
  .work-section{
    @include display-flex(column, flex-start);
    flex: 1 0 0;
    margin: 0 1em;
    :global(.claims-infobox-wrapper){
      margin-block-end: 1em;
    }
  }
  .items-lists-section{
    @include display-flex(column, center);
    inline-size: 100%;
    margin: 1em 0;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .editions-section-wrapper{
    flex: 1;
    &.no-edition{
      flex: 0.4;
    }
  }
  .relatives-lists{
    margin-block-start: 1em;
    align-self: stretch;
  }
  /* Small screens */
  @media screen and (max-width: $small-screen){
    .work-section{
      margin-inline-start: 0;
      :global(.claims-infobox-wrapper){
        margin-block-end: 0;
      }
      :global(.summary.has-summary){
        margin-block-start: 1em;
      }
    }
    .top-section{
      @include display-flex(column, center);
    }
    .editions-section-wrapper{
      inline-size: 100%;
      margin-block-start: 1em;
    }
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
