import map_ from './lib/map'

export default function () {
  app.commands.setHandlers({
    'show:position:picker:main:user': map_.showMainUserPositionPicker,
    'show:position:picker:group': showGroupPositionPicker,
    'show:models:on:map': showModelsOnMap
  })

  app.reqres.setHandlers({
    'prompt:group:position:picker': promptGroupPositionPicker,
    'map:before': map_.getLeaflet
  })
}

const showGroupPositionPicker = async (group, focusSelector) => {
  await map_.getLeaflet()
  map_.updatePosition(group, 'group:update:settings', 'group', focusSelector)
}

// Returns a promise that should resolve with the selected coordinates
const promptGroupPositionPicker = async () => {
  await map_.getLeaflet()
  return new Promise((resolve, reject) => {
    try {
      map_.showPositionPicker({ resolve, type: 'group' })
    } catch (err) {
      reject(err)
    }
  })
}

const showModelsOnMap = async models => {
  const [ { default: SimpleMap } ] = await Promise.all([
    import('./views/simple_map'),
    map_.getLeaflet()
  ])
  app.layout.modal.show(new SimpleMap({ models }))
}
