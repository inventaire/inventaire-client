import { forceArray } from '#lib/utils'
import UserMarker from '../user_marker.svelte'
import ItemMarker from '../item_marker.svelte'
import * as L from 'leaflet'

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

export const buildMarkers = (items, markers) => {
  const getFiltersValues = doc => [ doc.transaction, doc.entity ]
  for (let doc of items) {
    if (notMainUserOwner(doc) && !markers.has(doc.id)) {
      const marker = buildMarker(doc, getFiltersValues)
      markers.set(doc.id, marker)
    }
  }
  // add main user at initialisation, leave leaflet handle if marker is alredy created
  if (app.user.loggedIn && app.user.get('position') && !markers.has(app.user.id)) {
    markers.set(app.user.id, buildMainUserMarker())
  }
  return markers
}

export const isFilterSelected = (marker, selectedFilters) => {
  if (!selectedFilters) return true
  const filtersValues = marker.options.filters
  const markerSelectedFilters = _.intersection(filtersValues, selectedFilters)
  return _.isEqual(markerSelectedFilters, filtersValues)
}

const notMainUserOwner = doc => doc.owner !== app.user.id

const buildMarker = (doc, getFiltersValues) => {
  const { position, markerType } = doc
  if (!position || !markerType) return

  const markerOptions = markersConfigByTypes[markerType]

  // Wrapper enables to pass a full svelte component,
  // passing the component to the icon div appears to have some mounting problems
  // see https://imfeld.dev/writing/leaflet_with_svelte
  let iconWrapper = L.DomUtil.create('div')
  const Marker = markerOptions.markerComponent
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
    markerComponent: ItemMarker,
    className: 'itemMarker'
  },
  'main-user': {
    markerComponent: UserMarker,
    className: 'mainUserMarker'
  },
  user: {
    markerComponent: UserMarker,
    className: 'userMarker'
  }
}

const buildMainUserMarker = () => {
  const user = {}
  user.position = app.user.get('position')
  user.username = app.user.get('username')
  user.picture = app.user.get('picture')
  user.markerType = 'main-user'
  return buildMarker(user)
}

