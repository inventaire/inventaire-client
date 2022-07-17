import endpoint from './endpoint.js'
const { action } = endpoint('lists')

export default {
  byId (id) {
    return action('by-ids', {
      ids: id,
    })
  },
  update: '/api/lists',
}
