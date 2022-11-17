<script>
  import { onChange } from '#lib/svelte/svelte'
  import L from 'leaflet'
  import { getContext, onDestroy, onMount } from 'svelte'

  export let latLng
  const layer = getContext('layer')()

  let marker, markerElement

  function createMarker () {
    let icon = L.divIcon({
      html: markerElement,
      // Let the children elements determine the size
      iconSize: [ 0, 0 ]
    })
    marker = L.marker(latLng, { icon }).addTo(layer)
  }

  function updateMarker () {
    if (marker) {
      marker.setLatLng(latLng).update()
    }
  }

  function destroyMarker () {
    if (marker) {
      marker.removeFrom(layer)
      marker.remove()
      marker = null
    }
  }

  onMount(createMarker)
  onDestroy(destroyMarker)
  $: onChange(latLng, updateMarker)
</script>

<div bind:this={markerElement}>
  {#if marker}
    <slot />
  {/if}
</div>
