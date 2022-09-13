import endpoint from './endpoint.js'
const { base, action } = endpoint('lists')

export default {
  byId (id) {
    return action('by-id', { id })
  },
  byCreators (usersIds) {
    return action('by-creators', { users: usersIds })
  },
  byEntities (uris) {
    return action('by-entities', { uris })
  },
  create: action('create'),
  update: base,
  addElements: action('add-elements'),
  removeElements: action('remove-elements'),
}
