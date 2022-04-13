<script>
  import map_ from '#map/lib/map'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'
  import SimpleMap from '#map/components/simple_map.svelte'
  import MapFilters from '#map/components/map_filters.svelte'
  import { markersConfigByTypes, getBounds } from './lib/map'
  import { getFiltersData } from './lib/filters'

  const markerOptions = markersConfigByTypes.item

  export let initialDocs
  export let docsToDisplay = []
  let idsToDisplay = []

  const { filtersData } = getFiltersData.transaction
  // All selectedFilters values must be declared initially, otherwise reset could be incomplete
  let allFilters = Object.keys(filtersData)
  let selectedFilters = allFilters

  const getFiltersValues = doc => [ doc.transaction ]

  let bounds
  const syncDocValues = () => {
    bounds = getBounds(docsToDisplay)
    idsToDisplay = docsToDisplay.map(_.property('id'))
  }

  const resetDocsToDisplay = () => docsToDisplay = initialDocs

  $: notAllDocsAreDisplayed = docsToDisplay.length !== initialDocs.length
  $: docsToDisplay && syncDocValues()
</script>
{#await map_.getLeaflet()}
  <div class="loading-wrapper">
    <p class="loading">{I18n('loading map...')} <Spinner/></p>
  </div>
{:then}
  <div class="items-map">
    <SimpleMap
      {markerOptions}
      {bounds}
      {initialDocs}
      bind:selectedFilters
      {idsToDisplay}
      {getFiltersValues}
    />
    <MapFilters
      {allFilters}
      bind:selectedFilters
      data={getFiltersData.transaction}
    />
  </div>
  {#if notAllDocsAreDisplayed}
    <div class='show-all-wrapper'>
      <button class="show-all-button" on:click={resetDocsToDisplay}>
        {I18n('show every books on map')}
      </button>
    </div>
  {/if}
{/await}
<style lang="scss">
  @import '#general/scss/utils';
  @import '#map/scss/objects_markers';
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
