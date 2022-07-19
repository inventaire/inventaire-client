import endpoint from './endpoint.js'
const { action } = endpoint('lists')

export default {
  byId (id) {
    return action('by-id', { id })
  },
  update: '/api/lists',
  addSelections: action('add-selections'),
  removeSelections: action('remove-selections'),
}
