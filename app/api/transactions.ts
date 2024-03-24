import endpoint from './endpoint.js'
const { base, action } = endpoint('transactions')

export default {
  base,
  byItem: itemId => {
    return action('by-item', { item: itemId })
  },
}
