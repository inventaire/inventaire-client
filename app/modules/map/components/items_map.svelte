<script>
  import Spinner from '#general/components/spinner.svelte'
  import { transactionsData } from '#inventory/lib/transactions_data'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import MapFilters from '#map/components/map_filters.svelte'
  import SimpleMap from '#map/components/simple_map.svelte'
  import map_ from '#map/lib/map'
  import { I18n } from '#user/lib/i18n'
  import { buildMainUserMarker, buildMarker, getBounds } from './lib/map'

  export let docsToDisplay = []
  export let initialDocs, displayCover

  let allEditionsFilters, editionsFiltersData, selectedFilters, bounds
  let selectedTransactionFilters = []
  let selectedEditionFilters = []
  let transactionFiltersData = transactionsData
  let allTransactionFilters = []
  let idsToDisplay = []
  let markers = new Map()

  // onMount(() => bounds = initialBounds || getBounds(docsToDisplay))
  const syncDocValues = () => {
    bounds = getBounds(docsToDisplay)
    idsToDisplay = docsToDisplay.map(_.property('id'))
  }

  const buildMarkers = (items, markers) => {
    const getFiltersValues = doc => [ doc.transaction, doc.entity ]
    for (let doc of items) {
      if (!markers.has(doc.id)) {
        const marker = buildMarker(doc, getFiltersValues, displayCover)
        markers.set(doc.id, marker)
      }
    }
    // add main user at initialisation, leave leaflet handle if marker is alredy created
    if (app.user.loggedIn && app.user.get('position') && !markers.has(app.user.id)) {
      markers.set(app.user.id, buildMainUserMarker())
    }
    return markers
  }

  const resetDocsToDisplay = () => docsToDisplay = initialDocs

  const setMap = async items => {
    allEditionsFilters = []

    editionsFiltersData = items.reduce((filtersData, item) => ({ ...filtersData, [item.entity]: item }), {})

    if (isNonEmptyArray(items)) {
      allEditionsFilters = _.uniq(items.map(_.property('entity')))
    }
    selectedEditionFilters = allEditionsFilters
    selectedTransactionFilters = allTransactionFilters
    buildMarkers(items, markers)
  }

  $: {
    selectedFilters = [ ...selectedTransactionFilters, ...selectedEditionFilters ]
  }
  $: docsToDisplay && syncDocValues()
  $: notAllDocsAreDisplayed = docsToDisplay.length !== initialDocs.length
  $: {
    setMap(docsToDisplay)
  }
</script>
{#await map_.getLeaflet()}
  <div class="loading-wrapper">
    <p class="loading">{I18n('loading map...')} <Spinner/></p>
  </div>
{:then}
  <div class="items-map">
    <SimpleMap
      {bounds}
      {markers}
      bind:selectedFilters
      {idsToDisplay}
    />
    <MapFilters
      type='transaction'
      bind:selectedFilters={selectedTransactionFilters}
      filtersData={transactionFiltersData}
      bind:allFilters={allTransactionFilters}
    />
    {#if allEditionsFilters.length > 1}
      <MapFilters
        type='editions'
        bind:selectedFilters={selectedEditionFilters}
        filtersData={editionsFiltersData}
        bind:allFilters={allEditionsFilters}
      />
    {/if}
  </div>
  {#if notAllDocsAreDisplayed}
    <div class="show-all-wrapper">
      <button class="show-all-button" on:click={resetDocsToDisplay}>
        {I18n('show every books on map')}
      </button>
    </div>
  {/if}
{/await}
<style lang="scss">
  @import '#general/scss/utils';
  .items-map{
    position: relative;
    // z-index known cases: editions lang dropdown
    z-index:0;
  }
  .show-all-wrapper{
    @include display-flex(column, flex-end);
    margin-bottom: 1em;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .items-map{
    margin-bottom: 1em;
  }
  .show-all-button{
    @include tiny-button($light-grey);
    @include text-hover(#333);
    margin: 0.2em;
    padding: 0.5em;
  }
</style>
