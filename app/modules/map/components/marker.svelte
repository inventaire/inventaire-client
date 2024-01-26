<script>
  import { onChange } from '#lib/svelte/svelte'
  import L from 'leaflet'
  import { getContext, onDestroy, onMount, tick } from 'svelte'
  import log_ from '#lib/loggers'

  export let latLng
  export let standalone = false
  export let markerType = null
  export let metersRadius = 200
  export let marker

  let markerElement

  const map = getContext('map')()
  const layer = getContext('layer')()
  const targetLayer = standalone ? map : layer

  async function createMarker () {
    if (!markerElement) await tick()
    if (marker) return
    if (!latLng) {
      log_.warn('can not create marker: missing latLng')
      return
    }
    if (markerType === 'circle') {
      // Use a large border ("weight") to make the marker easily visible even when very zoomed out
      marker = L.circle(latLng, { radius: metersRadius, weight: 10 }).addTo(targetLayer)
    } else {
      const icon = L.divIcon({
        html: markerElement,
        // Let the children elements determine the size
        iconSize: [ 0, 0 ]
      })
      marker = L.marker(latLng, { icon }).addTo(targetLayer)
    }
  }

  function updateMarkerLatLng () {
    if (marker) {
      marker.setLatLng(latLng).update()
    } else {
      createMarker()
    }
  }

  function destroyMarker () {
    if (marker) {
      marker.removeFrom(targetLayer)
      marker.remove()
      marker = null
    }
  }

  onMount(createMarker)
  onDestroy(destroyMarker)
  $: onChange(latLng, updateMarkerLatLng)
</script>

<div bind:this={markerElement}>
  {#if marker}
    <slot />
  {/if}
</div>
