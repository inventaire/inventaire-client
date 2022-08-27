<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
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
  import { setContext } from 'svelte'
  import { writable } from 'svelte/store'
  import Summary from '#entities/components/layouts/summary.svelte'

  export let entity, standalone

  let showMap

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

  let editionsList, windowScrollY
  const scrollToItemsList = () => {
    if (editionsList) { windowScrollY = editionsList.offsetTop }
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

<svelte:window bind:scrollY={windowScrollY} />
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
            on:showMap={() => showMap = true}
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
            <p class="loading">{I18n('looking for editions...')}
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
            bind:editions={editions}
            bind:itemsByEditions={itemsByEditions}
          />
        {/await}
      </div>
    </div>
    {#await editionsWithPublishers then}
      {#if someEditions}
        <div
          class="users-editions-section"
          bind:this={editionsList}
        >
          <ItemsLists
            {editionsUris}
            bind:showMap={showMap}
            bind:itemsUsers={itemsUsers}
            on:scrollToItemsList={scrollToItemsList}
            bind:itemsByEditions={itemsByEditions}
          />
        </div>
      {/if}
    {/await}
    <RelativeEntitiesList
      {entity}
      property="wdt:P921"
      label={I18n('works_about_entity', { name: entity.label })}
    />
    <HomonymDeduplicates
      {entity}
    />
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
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
  .users-editions-section{
    @include display-flex(column, center);
    width:100%;
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
