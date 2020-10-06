import Config from './lib/config'
import PositionPicker from './views/position_picker'
import SimpleMap from './views/simple_map'

const { init: onLeafletReady } = Config

const getLeaflet = async () => {
  await Promise.all([
    import('leaflet'),
    import('leaflet/dist/leaflet.css'),
    import('leaflet.markercluster/dist/MarkerCluster.css'),
    import('leaflet.markercluster/dist/MarkerCluster.Default.css'),
  ])
  await import('leaflet.markercluster'),
  console.log('L', window.L)
  onLeafletReady()
}

export default function () {
  app.commands.setHandlers({
    'show:position:picker:main:user': showMainUserPositionPicker,
    'show:position:picker:group': showGroupPositionPicker,
    'show:models:on:map': showModelsOnMap
  })

  app.reqres.setHandlers({
    'prompt:group:position:picker': promptGroupPositionPicker,
    'map:before': getLeaflet
  })
}

const showPositionPicker = options => app.layout.modal.show(new PositionPicker(options))

const updatePosition = (model, updateReqres, type, focusSelector) => showPositionPicker({
  model,
  type,
  focus: focusSelector,
  resolve (newCoords, selector) {
    return app.request(updateReqres, {
      attribute: 'position',
      value: newCoords,
      selector,
      // required by reqres updaters such as group:update:settings
      model
    })
  }
})

const showMainUserPositionPicker = async () => {
  await getLeaflet()
  updatePosition(app.user, 'user:update', 'user')
}

const showGroupPositionPicker = async (group, focusSelector) => {
  await getLeaflet()
  updatePosition(group, 'group:update:settings', 'group', focusSelector)
}

// Returns a promise that should resolve with the selected coordinates
const promptGroupPositionPicker = async () => {
  await getLeaflet()
  return new Promise((resolve, reject) => {
    try {
      showPositionPicker({ resolve, type: 'group' })
    } catch (err) {
      reject(err)
    }
  })
}

const showModelsOnMap = async models => {
  await getLeaflet()
  app.layout.modal.show(new SimpleMap({ models }))
}
