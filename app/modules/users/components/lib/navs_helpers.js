import User from '#users/models/user'
import Group from '#groups/models/group'
import { isOpenedOutside } from '#lib/utils'

export const isNotMainUser = user => user._id !== app.user.id

export const SelectInventoryOnClick = ({ type, doc }) => e => {
  if (isOpenedOutside(e)) return
  let model
  if (type === 'user') model = new User(doc)
  else if (type === 'group') model = new Group(doc)
  app.vent.trigger('inventory:select', type, model)
  e.preventDefault()
}
