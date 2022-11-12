<script>
  import L from 'leaflet'
  import { getContext } from 'svelte'

  export let latLng
  const layer = getContext('layer')()

  let marker
  function createMarker (markerElement) {
    let icon = L.divIcon({
      html: markerElement,
      // Let the children elements determine the size
      iconSize: [ 0, 0 ]
    })
    marker = L.marker(latLng, { icon }).addTo(layer)
    return {
      destroy () {
        if (marker) {
          marker.removeFrom(layer)
          marker.remove()
          marker = null
        }
      }
    }
  }
</script>

<div use:createMarker>
  {#if marker}
    <slot />
  {/if}
</div>
