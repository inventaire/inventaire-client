import { forceArray } from '#lib/utils'
import { getEndpointPathBuilders } from './endpoint.ts'

const { base, action } = getEndpointPathBuilders('lists')

export default {
  byId (id) {
    return action('by-id', { id })
  },
  byCreators ({ usersIds, withElements = false, offset, limit }) {
    usersIds = forceArray(usersIds).join('|')
    const params = {
      users: usersIds,
      'with-elements': withElements,
      offset,
      limit,
    }
    return action('by-creators', params)
  },
  byEntities ({ uris, lists }) {
    uris = forceArray(uris).join('|')
    const params = { uris }
    if (lists) {
      const listingsQueryString = forceArray(lists).join('|')
      Object.assign(params, { lists: listingsQueryString })
    }
    return action('by-entities', params)
  },
  create: action('create'),
  update: base,
  addElements: action('add-elements'),
  removeElements: action('remove-elements'),
  delete: action('delete'),
}
