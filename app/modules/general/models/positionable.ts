import Filterable from './filterable.ts'

// Extending Filterable as the models needing position feature
// happen to also need filterable features
export default Filterable.extend({
  hasPosition () { return this.has('position') },
  getCoords () {
    const latLng = this.get('position')
    if (latLng instanceof Array) {
      const [ lat, lng ] = latLng
      return { lat, lng }
    } else if (latLng != null) {
      return latLng
    } else {
      return {}
    }
  },

  getLatLng () {
    // Create a L.LatLng only once
    // Update it when position update (only required for the main user)
    this._latLng = this._latLng || this._setLatLng()
    return this._latLng
  },

  _setLatLng () {
    if (this.hasPosition()) {
      const [ lat, lng ] = this.get('position')
      // @ts-expect-error
      this._latLng = new L.LatLng(lat, lng)
    } else {
      this._latLng = null
    }
    return this._latLng
  },
})
