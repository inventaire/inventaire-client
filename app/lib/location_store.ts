import { readable } from 'svelte/store'
import { debounce } from 'underscore'
import app from '#app/app'
import { currentRoute, routeSection } from '#lib/location'

function getLocationData (section, route) {
  route = route || currentRoute()
  return {
    route,
    section: routeSection(route),
  }
}

export const locationStore = readable(getLocationData(), set => {
  const update = (section, route) => set(getLocationData(section, route))
  const lazyUpdate = debounce(update, 100)
  app.vent.on('route:change', lazyUpdate)
  return () => app.vent.off('route:change', lazyUpdate)
})
