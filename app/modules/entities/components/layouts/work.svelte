<script>
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
  import {
    workProperties,
  } from '#entities/components/lib/claims_helpers'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import { getSubEntities } from '../lib/entities'
  import BaseLayout from './base_layout.svelte'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import WikipediaExtract from './wikipedia_extract.svelte'
  import Ebooks from './ebooks.svelte'
  import ItemsLists from './items_lists.svelte'
  import EditionsList from './editions_list.svelte'

  export let entity, standalone, mapToShow

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
            propertiesLonglist={workProperties}
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
            {editionsWithPublishers}
            {someInitialEditions}
            {someEditions}
            bind:usersSize={usersSize}
            {publishersByUris}
            {entity}
            {initialEditions}
            bind:editions={editions}
            on:showMap={() => mapToShow = true}
            on:scrollToItemsList={scrollToItemsList}
          />
        {/await}
      </div>
    </div>
          <pre>######work.svelte:128 {JSON.stringify(usersSize, null, 2)}</pre>
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
            bind:usersSize={usersSize}
            {editionsUris}
            bind:mapToShow={mapToShow}
          />
        </div>
      {/if}
    {/await}
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  $entity-max-width: 650px;
  .entity-layout{
    @include display-flex(column, center);
    width: 100%;
  }
  .editions-section-wrapper{
    flex: 1 0 0;
    max-width: 50%;
  }
  .no-edition{
    flex: none;
    width: 15em;
  }
  .top-section{
    @include display-flex(row, flex-start, center);
    width: 100%;
    margin: 1em 0;
  }
  .work-section{
    @include display-flex(column, flex-start);
    flex: 1 0 0;
    margin: 0 1em;
  }
  .editions-list{
    @include display-flex(column, center);
  }
  .loading-wrapper{
    @include display-flex(column, center);
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
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
