<script>
  import {
    editionWorkProperties,
    workProperties,
    getLang,
  } from '#entities/components/lib/claims_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
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
  {entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="top-section">
      <div class="infobox">
        <AuthorsInfo
          {claims}
        />
        <Infobox
          {claims}
          propertiesLonglist={workProperties}
          propertiesShortlist={workShortlist}
        />
      </div>
    </div>
    <WikipediaExtract
      {entity}
    />
    <Ebooks
      {entity}
      {userLang}
    />
    <!-- TODO: works list -->
    {#await getEditionsWithPublishers()}
      <div class="loading-wrapper">
        <p class="loading">{I18n('looking for editions...')}
          <Spinner/>
        </p>
      </div>
    {:then}
      {#if someEditions}
        <div class="editions-wrapper">
          <h5 class="editions-title">
            {I18n('editions of this work')}
          </h5>
          <div class="actions-wrapper">
            <EditionsListActions
              bind:selectedLangs={selectedLangs}
              {editionsLangs}
              bind:triggerScrollToMap={triggerScrollToMap}
            />
          </div>
          <div class="lists">
            <div class="editions-list-wrapper">
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
            <div class="items-list-wrapper">
              <ItemsLists
                {editionsUris}
                {triggerScrollToMap}
              />
            </div>
          </div>
        </div>
      {/if}
    {/await}
  </div>
</BaseLayout>

<style lang="scss">
  @import '#general/scss/utils';
  $entity-max-width: 650px;

  .top-section{
    display: flex;
    margin-bottom: 1em;
  }
  .infobox{
    margin-bottom: 0.5em;
  }
  .editions-wrapper{
    border-top: 1px solid #ccc;
    @include display-flex(column, center);
  }
  .editions-title{
    @include display-flex(row, center, center);
  }
  .actions-wrapper{
    @include display-flex(row, center, center);
    min-height: 2em;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .edition-list{
    @include display-flex(row, center, space-between);
    background-color: $off-white;
    border: 1px solid #ddd;
    margin-bottom: 1em;
  }
  .lists{
    margin-top: 1em;
  }

  /*Large screens*/
  @media screen and (min-width: $small-screen) {
    .entity-layout{
      margin: 0 5em;
    }
  }

  /*Medium and large screens*/
  @media screen and (min-width: $entity-max-width) {
    .lists{
      display: flex;
    }
    .editions-list-wrapper{
      margin-right: 0.5em;
    }
    .items-list-wrapper{
      margin-left: 0.5em;
    }
  }

  /*Very small screens*/
  @media screen and (max-width: $very-small-screen) {
    .top-section{
      @include display-flex(column, center, center);
    }
    .infobox{
      @include display-flex(column, center);
      margin-bottom: 0.5em;
    }
  }
</style>
