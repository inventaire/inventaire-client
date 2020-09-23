/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import Filterable from './filterable'

// Extending Filterable as the models needing position feature
// happen to also need filterable features
export default Filterable.extend({
  hasPosition () { return this.has('position') },
  getCoords () {
    const latLng = this.get('position')
    if (latLng != null) {
      const [ lat, lng ] = Array.from(latLng)
      return { lat, lng }
    } else {
      return {}
    }
  },

  getLatLng () {
    // Create a L.LatLng only once
    // Update it when position update (only required for the main user)
    if (this._latLng != null) {
      return this._latLng
    } else { return this._setLatLng() }
  },

  _setLatLng () {
    if (this.hasPosition()) {
      const [ lat, lng ] = Array.from(this.get('position'))
      return this._latLng = new L.LatLng(lat, lng)
    } else {
      return this._latLng = null
    }
  }
})
