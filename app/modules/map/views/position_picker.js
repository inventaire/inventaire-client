import { tryAsync } from '#lib/promises'
import { getPositionFromNavigator } from '#map/lib/navigator_position'
import forms_ from '#general/lib/forms'
import error_ from '#lib/error'
import { startLoading, stopLoading, Check } from '#general/plugins/behaviors'
import positionPickerTemplate from './templates/position_picker.hbs'
import '../scss/position_picker.scss'
import AlertBox from '#behaviors/alert_box'
import General from '#behaviors/general'
import Loading from '#behaviors/loading'
import SuccessCheck from '#behaviors/success_check'
import { drawMap } from '#map/lib/draw'
import { updateMarker } from '#map/lib/map'
import { truncateDecimals } from '#map/lib/geo'

const containerId = 'positionPickerMap'

export default Marionette.View.extend({
  template: positionPickerTemplate,
  className: 'positionPicker',
  behaviors: {
    AlertBox,
    General,
    Loading,
    SuccessCheck,
  },

  events: {
    'click #validatePosition': 'validatePosition',
    'click #removePosition': 'removePosition'
  },

  initialize () {
    const { model } = this.options
    if (model != null) {
      this.hasPosition = model.hasPosition()
      this.position = model.getCoords()
    } else {
      this.hasPosition = false
      this.position = null
    }
  },

  serializeData () {
    return _.extend({}, typeStrings[this.options.type], {
      hasPosition: this.hasPosition,
      position: this.position
    })
  },

  onRender () {
    app.execute('modal:open', 'large', this.options.focus)
    // let the time to the modal to be fully open
    // so that the map can be drawned correctly
    this.setTimeout(this.initMap.bind(this), 500)
  },

  initMap () {
    if (this.hasPosition) {
      this._initMap(this.position)
    } else {
      getPositionFromNavigator(containerId)
      .then(this._initMap.bind(this))
    }

    this.$el.find('#validatePosition').focus()
  },

  _initMap (coords) {
    const { lat, lng, zoom } = coords
    const map = drawMap({
      containerId,
      latLng: [ lat, lng ],
      zoom,
      cluster: false
    })

    this.marker = map.addMarker({
      markerType: 'circle',
      metersRadius: this.getMarkerMetersRadius(),
      latLng: [ lat, lng ]
    })

    map.on('move', e => updateMarker(this.marker, e.target.getCenter()))
  },

  getCoords () {
    const { lat, lng } = this.marker._latlng
    return [ truncateDecimals(lat), truncateDecimals(lng) ]
  },

  validatePosition () { return this._updatePosition(this.getCoords(), '#validatePosition') },
  removePosition () { return this._updatePosition(null, '#removePosition') },
  _updatePosition (newCoords, selector) {
    startLoading.call(this, selector)

    this.position = newCoords

    return tryAsync(this.options.resolve.bind(null, newCoords, selector))
    .then(stopLoading.bind(this))
    .then(Check.call(this, '_updatePosition', this.close.bind(this)))
    .catch(error_.Complete('.alertBox'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  close () { app.execute('modal:close') },

  getMarkerMetersRadius () {
    if (this.options.type === 'group') return 20
    if (this.options.type === 'user') return 200
  }
})

const typeStrings = {
  user: {
    title: 'edit your position',
    context: 'position_privacy_context',
    tip: 'position_privacy_tip'
  },
  group: {
    title: "edit the group's position",
    context: 'group_position_context'
  }
}
