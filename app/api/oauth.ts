import endpoint from './endpoint.js'
const clientsEndpoint = endpoint('oauth/clients')

export default {
  authorize: '/api/oauth/authorize',
  clients: {
    byId: id => clientsEndpoint.action('by-ids', { ids: id }),
  }
}
