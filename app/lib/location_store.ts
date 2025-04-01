import { readable } from 'svelte/store'
import { debounce } from 'underscore'
import { currentRoute, routeSection, type ProjectRootRelativeUrl } from '#app/lib/location'
import { vent } from '#app/radio'

function getLocationData (section?: string, route?: ProjectRootRelativeUrl) {
  route = route || currentRoute()
  return {
    route,
    section: routeSection(route),
  }
}

export const locationStore = readable(getLocationData(), set => {
  const update = (section, route) => set(getLocationData(section, route))
  const lazyUpdate = debounce(update, 100)
  vent.on('route:change', lazyUpdate)
  return () => vent.off('route:change', lazyUpdate)
})
