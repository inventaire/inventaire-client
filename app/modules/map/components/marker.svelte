<script>
  import { onChange } from '#lib/svelte/svelte'
  import L from 'leaflet'
  import { getContext, onDestroy, onMount } from 'svelte'

  export let latLng, standalone = false

  const map = getContext('map')()
  const layer = getContext('layer')()
  const targetLayer = standalone ? map : layer

  let marker, markerElement

  function createMarker () {
    let icon = L.divIcon({
      html: markerElement,
      // Let the children elements determine the size
      iconSize: [ 0, 0 ]
    })
    marker = L.marker(latLng, { icon }).addTo(targetLayer)
  }

  function updateMarker () {
    if (marker) {
      marker.setLatLng(latLng).update()
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
  $: onChange(latLng, updateMarker)
</script>

<div bind:this={markerElement}>
  {#if marker}
    <slot />
  {/if}
</div>
