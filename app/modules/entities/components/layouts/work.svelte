<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
  import { getSubEntities } from '../lib/entities'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import { getWorkProperties } from '#entities/components/lib/claims_helpers'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import WikipediaExtract from './wikipedia_extract.svelte'
  import Ebooks from './ebooks.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionsList from './editions_list.svelte'
  import HomonymDeduplicates from './homonym_deduplicates.svelte'

  export let entity, standalone

  let showMap

  const omitAuthorsProperties = true
  const { uri } = entity
  let editionsUris
  let editions = []
  let initialEditions = []
  const userLang = app.user.lang
  let publishersByUris
  let usersSize = 0

  const workShortlist = [
    'wdt:P577',
    'wdt:P136',
    'wdt:P921',
  ]

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
  const getPublishersUrisFromEditions = editions => {
    return _.uniq(_.compact(_.flatten(editions.map(edition => {
      return findFirstClaimValue(edition, 'wdt:P123')
    }))))
  }

  const findFirstClaimValue = (entity, prop) => {
    const values = entity?.claims[prop]
    if (!values || !values[0]) return
    return values[0]
  }

  let editionsList, windowScrollY
  const scrollToItemsList = () => {
    if (editionsList) { windowScrollY = editionsList.offsetTop }
  }

  $: claims = entity.claims
  $: notOnlyP31 = Object.keys(claims).length > 1
  $: app.navigate(`/entity/${uri}`)
  $: if (isNonEmptyArray(editions)) {
    editionsUris = editions.map(_.property('uri'))
  }
  $: someEditions = editions && isNonEmptyArray(editions)
  $: someInitialEditions = initialEditions && isNonEmptyArray(initialEditions)
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
          <AuthorsInfo
            {claims}
          />
          <Infobox
            {claims}
            propertiesLonglist={getWorkProperties(omitAuthorsProperties)}
            propertiesShortlist={workShortlist}
          />
          <WikipediaExtract
            {entity}
          />
          <Ebooks
            {entity}
            {userLang}
          />
        </div>
      {/if}
      <div
        class="editions-section-wrapper"
        class:no-edition={!someEditions}
      >
        {#await editionsWithPublishers}
          <div class="loading-wrapper">
            <p class="loading">{I18n('looking for editions...')}
              <Spinner/>
            </p>
          </div>
        {:then}
          <EditionsList
            {someInitialEditions}
            {someEditions}
            bind:usersSize={usersSize}
            {publishersByUris}
            work={entity}
            {initialEditions}
            bind:editions={editions}
            on:showMap={() => showMap = true}
            on:scrollToItemsList={scrollToItemsList}
          />
        {/await}
      </div>
    </div>
    {#await editionsWithPublishers}
      <div class="loading-wrapper">
        <p class="loading">{I18n('looking for editions...')}
          <Spinner/>
        </p>
      </div>
    {:then}
      {#if someEditions}
        <div
          class="editions-list"
          bind:this={editionsList}
        >
          <!-- TODO: dont display items list if items owners are only main user items -->
          <ItemsLists
            {editionsUris}
            bind:showMap={showMap}
            bind:usersSize={usersSize}
            on:scrollToItemsList={scrollToItemsList}
          />
        </div>
      {/if}
    {/await}
    <HomonymDeduplicates
      {entity}
    />
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  $entity-max-width: 650px;
  .entity-layout{
    @include display-flex(column, center);
    width: 100%;
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
  .editions-list{
    @include display-flex(column, center);
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
  }

  /*Smaller screens*/
  @media screen and (max-width: $smaller-screen) {
    .top-section{
      @include display-flex(column);
    }
    .editions-section-wrapper{
      width: 100%;
      margin-top: 1em;
    }
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
