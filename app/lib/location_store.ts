import { readable } from 'svelte/store'
import { debounce } from 'underscore'
import { currentRoute, routeSection } from '#app/lib/location'
import { vent } from '#app/radio'

function getLocationData () {
  const route = currentRoute()
  return {
    route,
    section: routeSection(route),
  }
}

export const locationStore = readable(getLocationData(), set => {
  const update = () => set(getLocationData())
  const lazyUpdate = debounce(update, 100)
  vent.on('route:change', lazyUpdate)
  return () => vent.off('route:change', lazyUpdate)
})
