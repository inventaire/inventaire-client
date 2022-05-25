<script>
  import {
    editionWorkProperties,
    getLang
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

  const claimsOrder = [
    ...editionWorkProperties,
  ]

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
  $: someEditions = initialEditions && initialEditions.length > 1
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
  </div>
  <h5>{I18n('editions')}</h5>
  <div class="editions-wrapper">
    {#await getEditions()}
      <div class="loading-wrapper">
        <p class="loading">{I18n('looking for editions...')} <Spinner/></p>
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
        <div class="lists">
          <div class="editions-list-wrapper">
            {#each editions as edition (edition._id)}
              <EditionList {edition} {authorsUris}/>
            {/each}
          </div>
          <div class="items-list-wrapper">
            <ItemsLists
              {editionsUris}
              bind:triggerScrollToMap
            />
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
    width: 12em;
    margin: 0.2em;
  }
  .editions-list-wrapper{
    @include display-flex(column, stretch, space-between);
    margin-bottom: 1em;
    background-color: off-white;
  }
  .info-wrapper{
    @include display-flex(row, stretch, stretch);
    flex: 3 0 0;
    margin: 0;
    padding: 0 1em;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .editions-wrapper{
    width: 100%;
  }
  /*Large screens*/
  @media screen and (min-width: 1200px) {
    .lists{
      @include display-flex(row, flex-start, flex-start);
    }
    .editions-list-wrapper{
      margin: 0 0.5em;
      width: 50%;
    }
    .items-list-wrapper{
      width: 50%;
      margin: 0 0.5em;
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
