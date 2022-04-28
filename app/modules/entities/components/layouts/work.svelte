<script>
  import {
    editionWorkProperties,
    formatEntityClaim, getLang
  } from '#entities/components/lib/claims_helpers'
  import Spinner from '#general/components/spinner.svelte'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { I18n, i18n } from '#user/lib/i18n'
  import { getSubEntities } from '../lib/entities'
  import ClaimsInfobox from './claims_infobox.svelte'
  import EditionList from './edition_list.svelte'
  import EditionActions from './edition_actions.svelte'
  import EditionsListActions from './editions_list_actions.svelte'
  import EditDataActions from './edit_data_actions.svelte'
  import ItemsLists from './items_lists.svelte'

  export let entity, standalone, triggerScrollToMap

  const { uri } = entity
  let { claims } = entity
  let displayedClaims = []
  let authorsUris, editionsUris
  let editions = []
  let initialEditions = []
  let editionsLangs
  let selectedLangs = [ app.user.lang ]

  const claimsOrder = [
    ...editionWorkProperties,
    'wdt:P856', // official website
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
<div class="layout">
  {#if standalone}
    <h3>{I18n(entity.type)}</h3>
  {/if}
  <div class="entity-wrapper">
    <EditDataActions {entity} />
    <div class="entity">
      <div class="title-box">
        <h2 class="edition-title">{entity.label}</h2>
        {#if isNonEmptyArray(authorsUris)}
          <h3 class="edition-authorsUris">
            {i18n('by')}
            {@html formatEntityClaim({ values: authorsUris, prop: 'wdt:P50', omitLabel: true })}
          </h3>
        {/if}
        <div class="info-wrapper">
          <div class="claims-infobox">
            <ClaimsInfobox claims={displayedClaims} {uri} {claimsOrder}/>
          </div>
          <div class="entity-buttons">
            <EditionActions {entity}/>
          </div>
        </div>
      </div>
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
</div>

<style lang="scss">
  @import '#general/scss/utils';
  .actions-wrapper{
    @include display-flex(row, center, center);
    min-height: 2em;
    padding-bottom: 1em;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .layout{
    @include display-flex(column, center, center);
    margin: 0 auto;
    max-width: 80em;
    background-color: white;
  }
  .edition-title{
    margin: 0;
    padding: 0;
    font-weight: bold;
    font-size: 1.5em;
  }
  .edition-authorsUris{
    margin-bottom: 0.5em;
    font-size: 1.2em;
  }
  .entity-wrapper{
    width: 100%;
    padding: 0 1em;
  }
  .entity{
    @include display-flex(row, stretch, stretch);
    margin-bottom: 2em;
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
  .claims-infobox{
    flex: 3 0 0;
    margin-bottom: 2em;
    margin-right: 2em;
  }
  .entity-buttons{
    @include display-flex(column, stretch);
    max-width: 20em;
  }
  .editions-wrapper{
    width: 100%;
  }
  /*large screens*/
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
  /*small and medium screens*/
  @media screen and (max-width: $small-screen) {
    .info-wrapper{
      @include display-flex(column, center);
    }
  }
  /*Small screens*/
  @media screen and (max-width: $smaller-screen) {
    .layout{
      @include display-flex(column, center, flex-start);
    }
    .title-box{
      @include display-flex(column, center);
    }
    .entity-wrapper{
      width: 100%;
      padding: 0;
    }
    .entity{
      @include display-flex(column, center);
      min-width: 100%;
    }
    .claims-infobox{
      margin: 1em 0;
    }
    .editions-list-wrapper{
      width: 100%;
    }
  }
</style>
