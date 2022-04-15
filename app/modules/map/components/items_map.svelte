<script>
  import map_ from '#map/lib/map'
  import Spinner from '#general/components/spinner.svelte'
  import { I18n } from '#user/lib/i18n'
  import SimpleMap from '#map/components/simple_map.svelte'
  import MapFilters from '#map/components/map_filters.svelte'
  import { buildMarker, getBounds, buildMainUserMarker } from './lib/map'
  import { getFiltersData } from './lib/filters'
  import { onMount } from 'svelte'

  export let initialDocs, initialBounds
  export let docsToDisplay = []

  let idsToDisplay = []
  let markers = new Map()

  const { filtersData } = getFiltersData.transaction
  // All selectedFilters values must be declared initially, otherwise reset could be incomplete
  let allFilters = Object.keys(filtersData)
  let selectedFilters = allFilters

  let bounds
  onMount(() => bounds = initialBounds || getBounds(docsToDisplay))
  const syncDocValues = () => {
    bounds = getBounds(docsToDisplay)
    idsToDisplay = docsToDisplay.map(_.property('id'))
  }

  const buildMarkers = (initialDocs, markers) => {
    for (let doc of initialDocs) {
      const getFiltersValues = doc => [ doc.transaction ]
      const marker = buildMarker(doc, getFiltersValues)
      markers.set(doc.id, marker)
    }
    if (app.user.loggedIn && !markers.has(app.user.id)) {
      markers.set(app.user.id, buildMainUserMarker())
    }
    return markers
  }

  buildMarkers(initialDocs, markers)

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
      {bounds}
      {markers}
      bind:selectedFilters
      {idsToDisplay}
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
