import { getEndpointPathBuilders } from './endpoint.ts'

const { base, action } = getEndpointPathBuilders('transactions')

export default {
  base,
  byItem: itemId => {
    return action('by-item', { item: itemId })
  },
}
