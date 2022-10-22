import { getLeaflet, showMainUserPositionPicker, showPositionPicker, updatePosition } from '#map/lib/map'

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
  const [ { default: SimpleMap } ] = await Promise.all([
    import('./views/simple_map.js'),
    getLeaflet(),
  ])
  app.layout.showChildView('modal', new SimpleMap({ models }))
}
