import map_ from '../lib/map';
import getPositionFromNavigator from 'modules/map/lib/navigator_position';
import forms_ from 'modules/general/lib/forms';
import error_ from 'lib/error';
import { startLoading, stopLoading, Check } from 'modules/general/plugins/behaviors';
const containerId = 'positionPickerMap';

export default Marionette.ItemView.extend({
  template: require('./templates/position_picker'),
  className: 'positionPicker',
  behaviors: {
    AlertBox: {},
    Loading: {},
    SuccessCheck: {},
    General: {}
  },

  events: {
    'click #validatePosition': 'validatePosition',
    'click #removePosition': 'removePosition'
  },

  initialize() {
    const { model } = this.options;
    if (model != null) {
      this.hasPosition = model.hasPosition();
      return this.position = model.getCoords();
    } else {
      this.hasPosition = false;
      return this.position = null;
    }
  },

  serializeData() {
    return _.extend({}, typeStrings[this.options.type], {
      hasPosition: this.hasPosition,
      position: this.position
    }
    );
  },

  onShow() {
    app.execute('modal:open', 'large', this.options.focus);
    // let the time to the modal to be fully open
    // so that the map can be drawned correctly
    return this.setTimeout(this.initMap.bind(this), 500);
  },

  initMap() {
    if (this.hasPosition) { this._initMap(this.position);
    } else {
      getPositionFromNavigator(containerId)
      .then(this._initMap.bind(this));
    }

    return this.$el.find('#validatePosition').focus();
  },

  _initMap(coords){
    const { lat, lng, zoom } = coords;
    const map = map_.draw({
      containerId,
      latLng: [ lat, lng ],
      zoom,
      cluster: false
    });

    this.marker = map.addMarker({
      markerType: 'circle',
      metersRadius: this.getMarkerMetersRadius(),
      latLng: [ lat, lng ]});

    return map.on('move', updateMarker.bind(null, this.marker));
  },

  getCoords() {
    const { lat, lng } = this.marker._latlng;
    return [ lat, lng ];
  },

  validatePosition() { return this._updatePosition(this.getCoords(), '#validatePosition'); },
  removePosition() { return this._updatePosition(null, '#removePosition'); },
  _updatePosition(newCoords, selector){
    startLoading.call(this, selector);

    this.position = newCoords;

    return Promise.try(this.options.resolve.bind(null, newCoords, selector))
    .then(stopLoading.bind(this))
    .then(Check.call(this, '_updatePosition', this.close.bind(this)))
    .catch(error_.Complete('.alertBox'))
    .catch(forms_.catchAlert.bind(null, this));
  },

  close() { return app.execute('modal:close'); },

  getMarkerMetersRadius() {
    switch (this.options.type) {
      case 'group': return 20;
      case 'user': return 200;
    }
  }
});

var typeStrings = {
  user: {
    title: 'edit your position',
    context: 'position_privacy_context',
    tip: 'position_privacy_tip'
  },
  group: {
    title: "edit the group's position",
    context: 'group_position_context'
  }
};
// tip: 'position_privacy_tip'

var updateMarker = (marker, e) => map_.updateMarker(marker, e.target.getCenter());
