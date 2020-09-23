/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import userMarker from '../views/templates/user_marker'
import groupMarker from '../views/templates/group_marker'
import itemMarker from '../views/templates/item_marker'
import customIcon from './custom_icon'

const objectMarker = markerBuilder => function (params) {
  const { model } = params
  const { lat, lng } = model.getCoords()
  const html = markerBuilder(model.serializeData())
  const icon = customIcon(html)
  const marker = L.marker([ lat, lng ], { icon })
  return marker
}

const markers = {
  user: objectMarker(userMarker),
  group: objectMarker(groupMarker),
  item: objectMarker(itemMarker),
  circle (params) {
    let { latLng, metersRadius } = params
    if (metersRadius == null) { metersRadius = 200 }
    return L.circle(latLng, metersRadius)
  }
}

export default function (params) {
  const { markerType } = params
  return markers[markerType](params)
};
