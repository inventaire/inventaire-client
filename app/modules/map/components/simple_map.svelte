<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { buildMarker, getBounds } from './lib/map'
  import isMobile from '#lib/mobile_check'
  import mapConfig from '#map/lib/config.js'

  const { tileUrl, settings } = mapConfig

  export let markerOptions, bounds, initialDocs, selectedFilters, idsToDisplay, getFiltersValues

  // All filter values must be declared initially, otherwise reset could be incomplete
  const allFilters = selectedFilters

  let map, markersLayer
  let markers = new Map()

  const initMap = container => {
    map = L.map(container)
    bounds = isNonEmptyArray(bounds) ? bounds : getBounds(initialDocs)
    let isCluster = initialDocs.length > 2
    if (isCluster) {
    // See options https://github.com/Leaflet/Leaflet.markercluster#options
      markersLayer = L.markerClusterGroup()
    } else {
      markersLayer = L.layerGroup()
    }
    L.tileLayer(tileUrl, settings).addTo(map)
    if (isMobile) map.scrollWheelZoom.disable()
    buildMarkers(initialDocs)
    syncMarkers()
    map.addLayer(markersLayer)
  }

  const buildMarkers = initialDocs => {
    for (let doc of initialDocs) {
      const marker = buildMarker(markerOptions, doc, getFiltersValues)
      markers.set(doc.id, marker)
    }
  }

  const syncMarkers = () => {
    // Parsing all markers for updating only a filter is not efficient,
    // but it leaves room for having more than one type of filters.
    // A more efficient alternative would be to store markers by filter and update accordingly,
    // but then, intricacy between filters and markers might make future refactors harder.
    for (let markerKeyValue of markers.entries()) syncMarker(...markerKeyValue)
  }

  const syncMarker = (docId, marker) => {
    if (isFilterSelected(marker) && idsToDisplay.includes(docId)) {
      markersLayer.addLayer(marker)
    } else {
      markersLayer.removeLayer(marker)
    }
  }

  const isFilterSelected = marker => {
    const filtersValues = marker.options.filters
    const filters = _.intersection(selectedFilters, filtersValues)
    return isNonEmptyArray(filters)
  }

  const reset = () => {
    selectedFilters = allFilters
    syncMarkers()
  }

  const resizeMap = () => {
    // used to ease development, but could be useful for prodcution
    if (map) { map.invalidateSize() }
  }

  $: {
    if (selectedFilters) syncMarkers()
  }
  $: {
    reset(idsToDisplay)
  }
  $: {
    if (map) {
      if (bounds.length === 1) {
        const zoom = 9
        map.setView(bounds[0], zoom)
      } else {
        map.fitBounds(bounds)
      }
    }
  }
</script>
<svelte:window on:resize={resizeMap} />
<div class="simple-map" use:initMap/>
<style lang="scss">
  @import '#general/scss/utils';
  .simple-map{
    height: 30em;
    width: 100%;
  }
</style>
