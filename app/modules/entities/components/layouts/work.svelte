<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { i18n } from '#user/lib/i18n'
  import { getSubEntities } from '../lib/entities'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import { getPublishersUrisFromEditions, removeAuthorsClaims } from '#entities/components/lib/work_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import EntityImage from '../entity_image.svelte'
  import Infobox from './infobox.svelte'
  import Ebooks from './ebooks.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionsList from './editions_list.svelte'
  import EntityTitle from './entity_title.svelte'
  import WorkActions from './work_actions.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'
  import RelativeEntitiesList from '#entities/components/layouts/relative_entities_list.svelte'
  import { setContext, tick } from 'svelte'
  import { writable } from 'svelte/store'
  import Summary from '#entities/components/layouts/summary.svelte'
  import screen_ from '#lib/screen'

  export let entity, standalone

  let showMap, itemsListsWrapperEl, mapWrapperEl

  const { uri } = entity
  let editionsUris
  let editions = []
  let initialEditions = []
  const userLang = app.user.lang
  let publishersByUris
  let itemsUsers = 0
  let itemsByEditions = {}

  setContext('work-layout:filters-store', writable({}))

  const getEditionsWithPublishers = async () => {
    initialEditions = await getSubEntities('work', uri)
    const publishersUris = getPublishersUrisFromEditions(initialEditions)
    const { entities } = await getEntitiesAttributesByUris({
      uris: publishersUris,
      attributes: [ 'labels' ],
      lang: userLang
    })
    publishersByUris = entities
    editions = initialEditions
  }

  let editionsWithPublishers = getEditionsWithPublishers()

  async function showMapAndScrollToMap () {
    showMap = true
    await tick()
    screen_.scrollToElement(mapWrapperEl, { marginTop: 10, waitForRoomToScroll: false })
  }

  const scrollToItemsList = () => {
    screen_.scrollToElement(itemsListsWrapperEl, { marginTop: 10, waitForRoomToScroll: false })
  }

  $: claims = entity.claims
  $: infoboxClaims = removeAuthorsClaims(entity.claims)
  $: notOnlyP31 = Object.keys(claims).length > 1
  $: app.navigate(`/entity/${uri}`)
  $: if (isNonEmptyArray(editions)) {
    editionsUris = editions.map(_.property('uri'))
  }
  $: someEditions = editions && isNonEmptyArray(editions)
  $: hasSomeInitialEditions = initialEditions && isNonEmptyArray(initialEditions)
</script>

<BaseLayout
  bind:entity={entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      {#if notOnlyP31}
        <div class="work-section">
          <EntityTitle {entity} {standalone}/>
          <AuthorsInfo
            {claims}
          />
          <div class="image-and-infobox">
            <div class="entity-image">
              <EntityImage
                entity={entity}
                size={192}
              />
            </div>
            <Infobox
              claims={infoboxClaims}
              entityType={entity.type}
            />
          </div>
          <Summary {entity} />
          <Ebooks
            {entity}
            {userLang}
          />
          <WorkActions
            {someEditions}
            bind:itemsUsers={itemsUsers}
            on:showMapAndScrollToMap={showMapAndScrollToMap}
            on:scrollToItemsList={scrollToItemsList}
          />
        </div>
      {/if}
      <div
        class="editions-section-wrapper"
        class:no-edition={!hasSomeInitialEditions}
      >
        {#await editionsWithPublishers}
          <div class="loading-wrapper">
            <p class="loading">{i18n('Looking for editions...')}
              <Spinner/>
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
          />
        {/await}
      </div>
    </div>
    {#await editionsWithPublishers then}
      {#if someEditions}
        <div class="items-lists-section">
          <ItemsLists
            {editionsUris}
            bind:showMap
            bind:itemsUsers
            bind:itemsByEditions
            bind:mapWrapperEl
            bind:itemsListsWrapperEl
            on:showMapAndScrollToMap={showMapAndScrollToMap}
          />
        </div>
      {/if}
    {/await}
    <div class="relatives-lists">
      <RelativeEntitiesList
        {entity}
        property="wdt:P144"
        label={i18n('works_based_on_work', { name: entity.label })}
      />
      <RelativeEntitiesList
        {entity}
        property="wdt:P941"
        label={i18n('works_inspired_by_work', { name: entity.label })}
      />
      <RelativeEntitiesList
        {entity}
        property="wdt:P921"
        label={i18n('works_about_entity', { name: entity.label })}
      />
    </div>
    <HomonymDeduplicates
      {entity}
    />
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  @import '#entities/scss/relatives_lists';
  .entity-layout{
    @include display-flex(column, center);
    width: 100%;
  }
  .image-and-infobox{
    @include display-flex(row, flex-start);
  }
  .entity-image{
    margin-right: 1em;
  }
  .no-edition{
    flex: none;
    width: 15em;
  }
  .top-section{
    @include display-flex(row, flex-start, center);
    width: 100%;
  }
  .work-section{
    @include display-flex(column, flex-start);
    flex: 1 0 0;
    margin: 0 1em;
  }
  .items-lists-section{
    @include display-flex(column, center);
    width: 100%;
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
    align-self: stretch;
  }
  /*Small screens*/
  @media screen and (max-width: $small-screen) {
    .work-section{
      margin-left: 0;
      margin-right: 1em;
    }
    .top-section{
      @include display-flex(column, center);
    }
    .editions-section-wrapper{
      width: 100%;
      margin-top: 1em;
    }
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
