<script>
  import {
    editionWorkProperties,
    workProperties,
    getLang,
  } from '#entities/components/lib/claims_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n, i18n } from '#user/lib/i18n'
  import { getSubEntities } from '../lib/entities'
  import AuthorsInfo from './authors_info.svelte'
  import Infobox from './infobox.svelte'
  import EditionList from './edition_list.svelte'
  import EditionsListActions from './editions_list_actions.svelte'
  import BaseLayout from './base_layout.svelte'
  import ItemsLists from './items_lists.svelte'
  import Ebooks from './ebooks.svelte'
  import { getEntitiesAttributesByUris } from '#entities/lib/entities'
  import WikipediaExtract from './wikipedia_extract.svelte'

  export let entity, standalone, triggerScrollToMap

  const { uri } = entity
  let authorsClaims, editionsUris
  let editions = []
  let initialEditions = []
  let editionsLangs
  const userLang = app.user.lang
  let selectedLangs = [ userLang ]
  let publishersByUris

  const allWorkProperties = _.uniq([
    ...editionWorkProperties,
    ...workProperties
  ])

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
      lang: app.user.lang
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

  const addClaims = claims => {
    const nonEmptyClaims = _.pick(claims, isNonEmptyArray)
    return Object.assign(claims, nonEmptyClaims)
  }
  const workClaims = _.pick(claims, allWorkProperties)
  addClaims(workClaims)

  const prioritizeMainUserLang = langs => {
    if (langs.includes(userLang)) {
      const userLangIndex = langs.indexOf(userLang)
      langs.splice(userLangIndex, 1)
      langs.unshift(userLang)
    }
    return langs
  }

  const filterEditionByLang = initialEditions => {
    if (selectedLangs.length === editionsLangs.length) {
      return editions = initialEditions
    }
    editions = initialEditions.filter(e => e.originalLang.includes(selectedLangs))
  }

  $: {
    if (initialEditions) {
      let rawEditionsLangs = _.uniq(initialEditions.map(getLang))
      editionsLangs = prioritizeMainUserLang(rawEditionsLangs)
    }
  }
  $: claims = entity.claims
  $: selectedLangs && filterEditionByLang(initialEditions)
  $: app.navigate(`/entity/${uri}`)
  $: if (isNonEmptyArray(editions)) {
    editionsUris = editions.map(_.property('uri'))
  }
  $: someEditions = initialEditions && isNonEmptyArray(initialEditions)
</script>

<BaseLayout
  bind:entity={entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
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
    <div class="editions-section"
      class:no-edition={!someEditions}
    >
      <div
        class="editions-list-wrapper"
        class:no-edition={!someEditions}
      >
        <div class="editions-list-title">
          <h5>
            {I18n('editions')}
          </h5>
        </div>
        {#await editionsWithPublishers}
          <div class="loading-wrapper">
            <p class="loading">{I18n('looking for editions...')}
              <Spinner/>
            </p>
          </div>
        {:then}
          {#if someEditions}
            <div class="actions-wrapper">
              <EditionsListActions
                bind:selectedLangs={selectedLangs}
                {editionsLangs}
                bind:triggerScrollToMap={triggerScrollToMap}
              />
            </div>
            <div class="editions-list">
              {#each editions as edition (edition._id)}
                <div class="edition-list">
                  <EditionList
                    {edition}
                    {authorsClaims}
                    {publishersByUris}
                  />
                </div>
              {/each}
            </div>
            <div class="editions-list">
              <ItemsLists
                {editionsUris}
                {triggerScrollToMap}
              />
            </div>
          {:else}
            <div class="no-edition-wrapper">
              {i18n('no editions found')}
            </div>
          {/if}
        {/await}
      </div>
      <!-- TODO: works list -->
    </div>
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  $entity-max-width: 650px;
  .entity-layout{
    @include display-flex(row, flex-start, space-between);
    width: 100%;
  }
  .editions-section{
    @include display-flex(row, flex-start, space-between);
    flex: 1 0 0;
    &.no-edition{
      flex: none !important;
    }
  }
  .work-section{
    @include display-flex(column, flex-start, space-between);
    flex: 1 0 0;
  }
  .editions-list{
    @include display-flex(column, center);
  }
  .editions-list-title{
    @include display-flex(row, center, center);
  }
  .actions-wrapper{
    @include display-flex(row, center, center);
    min-height: 2em;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .editions-list-wrapper{
    @include radius;
    padding: 0.5em;
    background-color: $off-white;
    &.no-edition{
      width: 10em;
    }
  }
  .edition-list{
    @include display-flex(row, flex-start, space-between);
    border-top:1px solid #ddd;
    width:100%;
  }
  .no-edition-wrapper{
    @include display-flex(row, center, center);
    color: $grey
  }

  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .entity-layout{
      margin-top: 1em;
    }
    .work-section{
      margin: 0 1em;
    }
  }

  /*Smaller screens*/
  @media screen and (max-width: $small-screen) {
    .work-section{
      @include display-flex(column);
      margin: 0;
      margin-right: 1em;
    }
    .editions-section{
    }
  }

  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .entity-layout{
      @include display-flex(column);
    }
  }
</style>
