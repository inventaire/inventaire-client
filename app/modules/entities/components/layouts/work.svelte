<script>
  import {
    editionWorkProperties,
    workProperties,
    getLang,
  } from '#entities/components/lib/claims_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray, isNonEmptyPlainObject } from '#lib/boolean_tests'
  import { I18n } from '#user/lib/i18n'
  import { getSubEntities, bestImage } from '../lib/entities'
  import Infobox from './infobox.svelte'
  import EditionList from './edition_list.svelte'
  import EditionsListActions from './editions_list_actions.svelte'
  import BaseLayout from './base_layout.svelte'
  import ItemsLists from './items_lists.svelte'
  import EntityImage from '../entity_image.svelte'

  export let entity, standalone, triggerScrollToMap

  const { uri, image } = entity
  let { claims } = entity
  let displayedClaims = []
  let authorsUris, editionsUris
  let editions = []
  let initialEditions = []
  let editionsLangs
  let selectedLangs = [ app.user.lang ]
  let mainCoverEdition, secondaryCoversEditions

  const claimsOrder = _.uniq([
    ...editionWorkProperties,
    ...workProperties
  ])

  const getEditions = async () => {
    initialEditions = await getSubEntities('work', uri)
    editions = initialEditions
  }

  const addClaims = claims => {
    authorsUris = claims['wdt:P50']
    delete claims['wdt:P50']
    const nonEmptyClaims = _.pick(claims, isNonEmptyArray)
    return Object.assign(claims, nonEmptyClaims)
  }

  const filterClaims = (_, key) => claimsOrder.includes(key)

  const workClaims = _.pick(claims, filterClaims)

  displayedClaims = addClaims(workClaims)

  if (authorsUris) {
    delete displayedClaims['wdt:P50']
  }

  const prioritizeMainUserLang = langs => {
    const userLang = app.user.lang
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

  const setEditionsImages = editions => {
    const editionsWithCover = editions.filter(edition => edition.image.url)
    .sort(bestImage)

    mainCoverEdition = editionsWithCover[0]
    secondaryCoversEditions = editionsWithCover.slice(1, 4)
  }

  $: {
    if (initialEditions) {
      let rawEditionsLangs = _.uniq(initialEditions.map(getLang))
      editionsLangs = prioritizeMainUserLang(rawEditionsLangs)
    }
  }

  $: selectedLangs && filterEditionByLang(initialEditions)
  $: app.navigate(`/entity/${uri}`)
  $: if (isNonEmptyArray(editions)) {
    editionsUris = editions.map(_.property('uri'))
  }
  $: someEditions = initialEditions && isNonEmptyArray(initialEditions)
  $: {
    if (isNonEmptyArray(editions)) setEditionsImages(editions)
  }
</script>
<BaseLayout
  {entity}
  {standalone}
>
  <div class="entity-layout" slot="entity">
    <div class="info-wrapper">
      <div class="info">
        <div class="covers">
          {#if isNonEmptyPlainObject(image)}
            <div class="main-cover">
              <EntityImage
                {entity}
                withLink={false}
                size={400}
              />
            </div>
          {:else if someEditions}
            {#if mainCoverEdition}
              <div class="main-cover">
                <EntityImage
                  entity={mainCoverEdition}
                  size={400}
                />
              </div>
              {#if isNonEmptyArray(secondaryCoversEditions)}
                <div class="secondary-covers">
                  {#each secondaryCoversEditions as edition (edition._id)}
                    <div class="secondary-cover">
                      <EntityImage
                        entity={edition}
                        size={150}
                      />
                    </div>
                  {/each}
                </div>
              {/if}
            {/if}
          {/if}
        </div>
      </div>
      <Infobox
        {entity}
        {authorsUris}
        {displayedClaims}
        {claimsOrder}
      />
    </div>
    <!-- TODO: works list -->
    {#await getEditions()}
      <div class="loading-wrapper">
        <p class="loading">{I18n('looking for editions...')} <Spinner/></p>
      </div>
    {:then}
      {#if someEditions}
        <div class="editions-wrapper">
          <h5 class="editions-title">
            {I18n('editions of this work')}
          </h5>
          <div class="lists">
            <div class="editions-list-wrapper">
              {#each editions as edition (edition._id)}
                <div class="edition-list">
                  <EditionList {edition} {authorsUris}/>
                </div>
              {/each}
              <div class="actions-wrapper">
                <EditionsListActions
                  bind:selectedLangs={selectedLangs}
                  {editionsLangs}
                  bind:triggerScrollToMap={triggerScrollToMap}
                />
              </div>
            </div>
            <div class="items-list-wrapper">
              <ItemsLists
                {editionsUris}
                bind:triggerScrollToMap
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
  .info-wrapper{
    display: flex;
    margin-bottom: 1em;
  }
  .info{
    display: flex;
  }
  .covers{
    @include display-flex(row, center, space-around);
    margin-bottom: 1em;
    margin-right: 1em;
  }
  .secondary-cover{
    max-width: 7em;
  }
  .main-cover, .secondary-cover{
    max-width: 10em;
    margin: 0.2em;
  }
  .editions-wrapper{
    border-top: 1px solid #ccc;
    @include display-flex(column, center);
    width:100%;
  }
  .editions-title{
    @include display-flex(row, center, center);
  }
  .actions-wrapper{
    @include display-flex(row, center, center);
    min-height: 2em;
    padding: 1em 0;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .editions-list-wrapper{
    background-color: off-white;
    margin-right: 1em;
  }
  .edition-list{
    @include display-flex(row, center, space-between);
    background-color: $off-white;
    border: 1px solid #ddd;
    margin: 0.2em;
  }
  /*Large screens*/
  @media screen and (min-width: $very-small-screen) {
    .lists{
      display: flex;
    }
    .editions-list-wrapper{
      margin-right: 0 0.5em;
    }
    .items-list-wrapper{
      margin-left: 0 0.5em;
    }
    .editions-wrapper{
      width: 100%;
    }
  }

  /*Very Small screens*/
  @media screen and (max-width: $very-small-screen) {
    .info-wrapper{
      @include display-flex(column, center, center);
    }
    .covers{
      align-self: stretch;
      flex-direction: column;
      margin: 1em 0 0 0;
    }
    .secondary-covers{
      align-self: stretch;
      @include display-flex(row, center, center);
    }
  }
</style>
