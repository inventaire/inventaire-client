import Filterable from './filterable'

// Extending Filterable as the models needing position feature
// happen to also need filterable features
export default Filterable.extend({
  hasPosition () { return this.has('position') },
  getCoords () {
    const latLng = this.get('position')
    if (latLng != null) {
      const [ lat, lng ] = latLng
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
    } else {
      return this._setLatLng()
    }
  },

  _setLatLng () {
    if (this.hasPosition()) {
      const [ lat, lng ] = this.get('position')
      this._latLng = new L.LatLng(lat, lng)
    } else {
      this._latLng = null
    }
  }
})
