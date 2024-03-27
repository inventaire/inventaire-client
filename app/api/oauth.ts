import { getEndpointPathBuilders } from './endpoint.ts'

const { action } = getEndpointPathBuilders('oauth/clients')

export default {
  authorize: '/api/oauth/authorize',
  clients: {
    byId: id => action('by-ids', { ids: id }),
  },
}
