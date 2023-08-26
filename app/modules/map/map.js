import { getLeaflet, showMainUserPositionPicker, showPositionPicker, updatePosition } from '#map/lib/map'

export default function () {
  app.commands.setHandlers({
    'show:position:picker:main:user': showMainUserPositionPicker,
    'show:position:picker:group': showGroupPositionPicker,
  })

  app.reqres.setHandlers({
    'prompt:group:position:picker': promptGroupPositionPicker,
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
