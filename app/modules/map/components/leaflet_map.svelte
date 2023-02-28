<!-- Inspired by https://imfeld.dev/writing/svelte_domless_components
     and https://github.com/ngyewch/svelte-leaflet -->
<script>
  import { createEventDispatcher, setContext } from 'svelte'
  import L from 'leaflet'
  import 'leaflet/dist/leaflet.css'
  import 'leaflet.markercluster/dist/MarkerCluster.css'
  import 'leaflet.markercluster/dist/MarkerCluster.Default.css'
  // Needs to be initialized after window.L was set
  import 'leaflet.markercluster'
  // TODO: split markers style between components
  import '#map/scss/objects_markers.scss'
  import mapConfig from '#map/lib/config.js'
  import isMobile from '#lib/mobile_check'

  mapConfig.init()

  // Must set either bounds, or view and zoom.
  export let bounds
  export let view
  export let zoom = 13
  export let cluster = false

  export let map

  let clusterGroup

  const dispatch = createEventDispatcher()

  setContext('map', () => map)
  setContext('layer', () => clusterGroup || map)

  function createLeaflet (node) {
    map = L.map(node, mapConfig.mapOptions)
      .on('zoom', e => dispatch('zoom', e))
      .on('moveend', e => dispatch('moveend', e))

    if (bounds) {
      map.fitBounds(bounds)
    } else {
      map.setView(view, zoom)
    }

    L.tileLayer(mapConfig.tileUrl, mapConfig.tileLayerOptions)
      .addTo(map)

    if (isMobile) map.scrollWheelZoom.disable()

    if (cluster) {
      clusterGroup = L.markerClusterGroup()
      map.addLayer(clusterGroup)
    }

    return {
      destroy () {
        map.remove()
        map = null
      },
    }
  }

  $: if (map) {
    if (bounds) {
      map.fitBounds(bounds)
    } else {
      map.setView(view, zoom)
    }
  }
</script>

<div use:createLeaflet>
  {#if map}
    <slot {map} />
  {/if}
</div>

<style>
  div{
    height: 100%;
    width: 100%;
  }
  :global(.leaflet-control-container){
    position: static;
  }
  :global(.leaflet-marker-icon){
    border: 0;
  }
</style>
