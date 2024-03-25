import endpoint from './endpoint.ts'

const clientsEndpoint = endpoint('oauth/clients')

export default {
  authorize: '/api/oauth/authorize',
  clients: {
    byId: id => clientsEndpoint.action('by-ids', { ids: id }),
  },
}
