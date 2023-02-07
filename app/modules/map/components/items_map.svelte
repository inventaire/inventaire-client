<script>
  import Spinner from '#general/components/spinner.svelte'
  import { transactionsData } from '#inventory/lib/transactions_data'
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import MapFilters from '#map/components/map_filters.svelte'
  import SimpleMap from '#map/components/simple_map.svelte'
  import { getLeaflet } from '#map/lib/map'
  import { i18n } from '#user/lib/i18n'
  import { buildMarkers, getBounds } from './lib/map'

  export let docsToDisplay = []
  export let initialDocs

  let allEditionsFilters, editionsFiltersData, selectedFilters, bounds
  let selectedTransactionFilters = []
  let selectedEditionFilters = []
  let allTransactionFilters = []
  let transactionFiltersData = {}
  let idsToDisplay = []
  let markers = new Map()

  // onMount(() => bounds = initialBounds || getBounds(docsToDisplay))
  const syncDocValues = () => {
    bounds = getBounds(docsToDisplay)
    idsToDisplay = docsToDisplay.map(_.property('id'))
  }

  const resetDocsToDisplay = () => docsToDisplay = initialDocs

  const setMap = async items => {
    allEditionsFilters = []

    if (isNonEmptyArray(items)) {
      allEditionsFilters = _.uniq(items.map(_.property('entity')))
      allTransactionFilters = _.uniq(items.map(_.property('transaction')))
    }
    editionsFiltersData = items.reduce((filtersData, item) => ({ ...filtersData, [item.entity]: item }), {})
    transactionFiltersData = _.pick(transactionsData, allTransactionFilters)
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
{#await getLeaflet()}
  <div class="loading-wrapper">
    <p class="loading">{i18n('Loading map...')} <Spinner /></p>
  </div>
{:then}
  <div class="items-map">
    <SimpleMap
      {bounds}
      {markers}
      bind:selectedFilters
      {idsToDisplay}
    />
    {#if allTransactionFilters.length > 1}
      <MapFilters
        type="transaction"
        bind:selectedFilters={selectedTransactionFilters}
        filtersData={transactionFiltersData}
        bind:allFilters={allTransactionFilters}
      />
    {/if}
    {#if allEditionsFilters.length > 1}
      <MapFilters
        type="editions"
        bind:selectedFilters={selectedEditionFilters}
        filtersData={editionsFiltersData}
        bind:allFilters={allEditionsFilters}
      />
    {/if}
  </div>
  {#if notAllDocsAreDisplayed}
    <div class="show-all-wrapper">
      <button class="show-all-button" on:click={resetDocsToDisplay}>
        {i18n('Show every books on map')}
      </button>
    </div>
  {/if}
{/await}
<style lang="scss">
  @import "#general/scss/utils";
  .items-map{
    position: relative;
    width: 100%;
  }
  .show-all-wrapper{
    @include display-flex(column, flex-end);
    margin-bottom: 1em;
  }
  .loading-wrapper{
    @include display-flex(column, center);
  }
  .show-all-button{
    @include tiny-button($light-grey);
    @include text-hover(#333);
    margin: 0.2em;
    padding: 0.5em;
  }
</style>
