import { isOpenedOutside } from '#lib/utils'
import simpleMapTemplate from './templates/simple_map.hbs'
import PreventDefault from '#behaviors/prevent_default'
import { drawMap } from '#map/lib/draw'
import { showModelsOnMap } from '#map/lib/map'

const containerId = 'simpleMap'

export default Marionette.View.extend({
  template: simpleMapTemplate,

  initialize () {
    this.models = this.options.models
  },

  behaviors: {
    PreventDefault,
  },

  onRender () {
    app.execute('modal:open', 'large', this.options.focus)
    // let the time to the modal to be fully open
    // so that the map can be drawned correctly
    this.setTimeout(this.initMap.bind(this), 500)
  },

  initMap () {
    const bounds = this.models.map(getPosition)

    const map = drawMap({
      containerId,
      bounds,
      cluster: this.models.length > 2
    })

    showModelsOnMap(map, this.models)
  },

  events: {
    'click .userMarker a': 'showUser',
    'click .itemMarker a': 'showItem'
  },

  showUser (e) {
    if (isOpenedOutside(e)) return
    e.stopPropagation()
    const userId = e.currentTarget.attributes['data-user-id'].value
    app.execute('show:inventory:user', userId)
  },

  showItem (e) {
    if (isOpenedOutside(e)) return
    e.stopPropagation()
    const itemId = e.currentTarget.attributes['data-item-id'].value
    app.execute('show:item:byId', itemId)
  }
})

const getPosition = model => model.get('position') || model.position
