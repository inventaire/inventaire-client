<!-- Inspired by https://imfeld.dev/writing/svelte_domless_components
     and https://github.com/ngyewch/svelte-leaflet -->
<script>
  import { createEventDispatcher, setContext, tick } from 'svelte'
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
  import { onChange } from '#lib/svelte/svelte'
  import Flash from '#lib/components/flash.svelte'
  import { uniqBounds } from '#map/lib/map'

  mapConfig.init()

  // Must set either bounds, or view and zoom.
  export let bounds = null
  export let view = null
  export let zoom = 13
  export let cluster = false

  export let map

  let clusterGroup, flash

  const dispatch = createEventDispatcher()

  setContext('map', () => map)
  setContext('layer', () => clusterGroup || map)

  async function createLeaflet (node) {
    try {
      // Let the time to Svelte to setup surrounding elements,
      // so that Leaflet picks up the right map size
      await tick()
      map = L.map(node, mapConfig.mapOptions)
        .on('zoom', e => {
          dispatch('zoom', e)
          zoom = e.target._zoom
        })
        .on('move', e => dispatch('move', e))
        .on('moveend', e => dispatch('moveend', e))

      if (bounds) {
        // Prevent leaflet bug when the passed bounds are only identical bounds
        bounds = uniqBounds(bounds)
        if (bounds.length === 1) {
          const zoom = 9
          map.setView(bounds[0], zoom)
        } else {
          map.fitBounds(bounds, { padding: [ 20, 20 ] })
        }
      } else {
        map.setView(view, zoom)
      }

      L.tileLayer(mapConfig.tileUrl, mapConfig.tileLayerOptions)
        .addTo(map)

      if (isMobile) map.scrollWheelZoom.disable()

      if (cluster) {
        clusterGroup = L.markerClusterGroup({
          // Required to prevent big marker icons to overlap
          spiderfyDistanceMultiplier: 4
        })
        map.addLayer(clusterGroup)
      }

      return {
        destroy () {
          map.remove()
          map = null
        },
      }
    } catch (err) {
      flash = err
    }
  }

  function init () {
    try {
      if (map) {
        if (bounds) {
          map.fitBounds(bounds, { maxZoom: zoom })
        } else {
          map.setView(view, zoom)
        }
      }
    } catch (err) {
      flash = err
    }
  }

  function onBoundsChange () {
    if (map) map.fitBounds(bounds, { maxZoom: zoom })
  }

  $: onChange(map, init)
  $: onChange(bounds, onBoundsChange)
</script>

<Flash state={flash} />

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
