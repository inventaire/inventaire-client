import { buildPath } from '#app/lib/location'
import preq from '#app/lib/preq'
import { fixedEncodeURIComponent } from '#app/lib/utils'
import { getCurrentLang } from '#modules/user/lib/i18n'

const nominatimEndpoint = 'https://nominatim.openstreetmap.org/search'

export async function searchLocationByText (searchText) {
  const url = buildPath(nominatimEndpoint, {
    q: fixedEncodeURIComponent(searchText),
    format: 'json',
    'accept-language': getCurrentLang(),
  })
  const results = await preq.get(url)
  return results.map(serializeNominatimResults)
}

function serializeNominatimResults (result) {
  result.description = getResultDescription(result)
  result.latLng = [
    parseFloat(result.lat),
    parseFloat(result.lon),
  ]
  return result
}

function getResultDescription ({ name, display_name: displayName }) {
  const displayNameParts = displayName.split(',')
  if (displayNameParts[0] === name) {
    return displayNameParts.slice(1).join(',')
  } else {
    return displayName
  }
}

export function fitResultBbox (map, result) {
  // See https://nominatim.org/release-docs/3.4/api/Output/#boundingbox
  const [ minLat, maxLat, minLng, maxLng ] = result.boundingbox
  const bounds = [
    [ minLat, minLng ],
    [ maxLat, maxLng ],
  ]
  map.fitBounds(bounds, { padding: [ 5, 5 ], maxZoom: 18 })
}
