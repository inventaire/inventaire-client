import type { RelativeUrl } from '#server/types/common'
import { getEndpointPathBuilders } from './endpoint.ts'

const { action } = getEndpointPathBuilders('oauth/clients')

export default {
  authorize: '/api/oauth/authorize' as RelativeUrl,
  clients: {
    byId: id => action('by-ids', { ids: id }),
  },
}
