import { forceArray } from '#lib/utils'
import endpoint from './endpoint.js'
const { base, action } = endpoint('lists')

export default {
  byId (id) {
    return action('by-id', { id })
  },
  byCreators (usersIds) {
    return action('by-creators', { users: usersIds })
  },
  byEntities ({ uris, lists }) {
    uris = forceArray(uris).join('|')
    lists = forceArray(lists).join('|')
    return action('by-entities', { uris, lists })
  },
  create: action('create'),
  update: base,
  addElements: action('add-elements'),
  removeElements: action('remove-elements'),
}
