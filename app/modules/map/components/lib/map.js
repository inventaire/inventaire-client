import { forceArray } from '#lib/utils'
import UserMarker from '../user_marker.svelte'
import ItemMarker from '../item_marker.svelte'
import * as L from 'leaflet'

export const buildMarker = (doc, getFiltersValues) => {
  const { position, markerType } = doc
  if (!position || !markerType) return

  const markerOptions = markersConfigByTypes[markerType]

  // Wrapper enables to pass a full svelte component,
  // passing the component to the icon div appears to have some mounting problems
  // see https://imfeld.dev/writing/leaflet_with_svelte
  let iconWrapper = L.DomUtil.create('div')
  const Marker = markerOptions.markerModel
  new Marker({
    target: iconWrapper,
    props: { doc }
  })
  const icon = L.divIcon({
    html: iconWrapper,
    className: `${markerOptions.className} objectMarker`
  })
  const [ lat, lng ] = position
  const options = {
    icon,
    doc
  }
  if (getFiltersValues) {
    const filtersValues = getFiltersValues(doc)
    Object.assign(options, { filters: filtersValues })
  }
  const marker = L.marker([ lat, lng ], options)
  return marker
}

const markersConfigByTypes = {
  item: {
    markerModel: ItemMarker,
    className: 'itemMarker'
  },
  user: {
    markerModel: UserMarker,
    className: 'userMarker'
  }
}

export const getDocsIdsToUpdate = (docsByFilters, filterValue, docsIdsToDisplay) => {
  if (!filterValue) return docsIdsToDisplay
  if (!docsByFilters[filterValue]) docsByFilters[filterValue] = []
  // This only updates markers within a specific filter, might be premature optimisation
  // TODO: storing docsIdsByFilters in its own reactive object
  return docsByFilters[filterValue].map(_.property('id'))
}

export const getBounds = docsWithPosition => {
  docsWithPosition = forceArray(docsWithPosition)
  const positions = Object.values(docsWithPosition.map(_.property('position')))
  return _.compact(positions)
}

export const buildMainUserMarker = () => {
  const user = {}
  user.position = app.user.get('position')
  user.username = app.user.get('username')
  user.picture = app.user.get('picture')
  user.markerType = 'user'
  return buildMarker(user)
}
