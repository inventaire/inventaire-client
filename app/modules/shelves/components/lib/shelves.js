import { i18n } from '#user/lib/i18n'
import { serializeShelf } from '#shelves/lib/shelves'
import ShelfModel from '#shelves/models/shelf'

export const serializeShelfData = (shelf, withoutShelf) => {
  let name, description, pathname, title, picture, iconData, iconLabel, isEditable

  if (withoutShelf) {
    name = title = i18n('Items without shelf')
    description = ''
    pathname = '/shelves/without'
  } else {
    ;({ name, description } = shelf)
    ;({ pathname, picture, iconData, iconLabel, isEditable } = serializeShelf(shelf))
    title = `${name}${description ? ` - ${description}` : ''}`
  }

  return { name, description, pathname, title, picture, iconData, iconLabel, isEditable }
}

export function loadShelfLink (shelf) {
  const model = new ShelfModel(shelf)
  app.vent.trigger('inventory:select', 'shelf', model)
}
