import { forceArray } from '#lib/utils'
import { getEndpointPathBuilders } from './endpoint.ts'

const { base, action } = getEndpointPathBuilders('shelves')

export default {
  base,
  byId (id) { return action('by-ids', { ids: id, 'with-items': true }) },
  byIds (ids) {
    ids = forceArray(ids).join('|')
    return action('by-ids', { ids, 'with-items': true })
  },
  byOwners (id) { return action('by-owners', { owners: id }) },
  addItems: action('add-items'),
  removeItems: action('remove-items'),
  create: action('create'),
  update: action('update'),
  delete: action('delete'),
}
