<script>
  import { isNonEmptyArray } from '#lib/boolean_tests'
  import { isFilterSelected } from './lib/map'
  import isMobile from '#lib/mobile_check'
  import mapConfig from '#map/lib/config.js'

  const { tileUrl, settings } = mapConfig

  export let bounds, markers, selectedFilters, idsToDisplay

  let allFilters = selectedFilters
  let map, markersLayer

  const initMap = container => {
    map = L.map(container)
    // Always having cluster map enable to display more markers if/when added later,
    // Who can do more can do less: clusters can handle uniq marker on map
    // See options https://github.com/Leaflet/Leaflet.markercluster#options
    markersLayer = L.markerClusterGroup()
    L.tileLayer(tileUrl, settings).addTo(map)
    if (isMobile) map.scrollWheelZoom.disable()
    syncMarkers()
    map.addLayer(markersLayer)
  }

  const syncMarkers = () => {
    // Parsing all markers for updating markers from only one filter is not efficient,
    // but it leaves room for having more than one type of filters.
    // A more efficient alternative would be to store markers by filter and update accordingly,
    // but then, intricacy between filters and markers might make future refactors harder.
    for (let markerKeyValue of markers.entries()) syncMarker(...markerKeyValue)
  }

  const syncMarker = (docId, marker) => {
    if (!marker) return
    if (docId === app.user.id) {
      markersLayer.addLayer(marker)
      // never remove main user
      return
    }
    if (isFilterSelected(marker, selectedFilters) && idsToDisplay.includes(docId)) {
      markersLayer.addLayer(marker)
    } else {
      markersLayer.removeLayer(marker)
    }
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
    if (map && selectedFilters) syncMarkers()
  }
  $: {
    if (map) reset(idsToDisplay)
  }
  $: {
    if (map && isNonEmptyArray(bounds)) {
      if (bounds.length === 1) {
        const zoom = 9
        map.setView(bounds[0], zoom)
      } else {
        map.fitBounds(bounds)
      }
    }
  }
</script>
<svelte:window on:resize={resizeMap}/>
<div class="simple-map" use:initMap/>
<style lang="scss">
  @import '#general/scss/utils';
  .simple-map{
    height: 30em;
    width: 100%;
  }
</style>
