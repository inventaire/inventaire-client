import { forceArray } from '#app/lib/utils'
import type { EntityUri } from '#server/types/entity'
import type { ListingId } from '#server/types/listing'
import type { UserId } from '#server/types/user'
import { getEndpointPathBuilders } from './endpoint.ts'

const { base, action } = getEndpointPathBuilders('lists')

export default {
  byId (id) {
    return action('by-id', { id })
  },
  byCreators ({ usersIds, withElements = false, offset, limit }: { usersIds: UserId[], withElements?: boolean, offset?: number, limit?: number }) {
    return action('by-creators', {
      users: forceArray(usersIds).join('|'),
      'with-elements': withElements,
      offset,
      limit,
    })
  },
  byEntities ({ uris, lists }: { uris: EntityUri[], lists?: ListingId[] }) {
    if (lists) {
      return action('by-entities', {
        uris: forceArray(uris).join('|'),
        lists: forceArray(lists).join('|'),
      })
    } else {
      return action('by-entities', {
        uris: forceArray(uris).join('|'),
      })
    }
  },
  create: action('create'),
  update: base,
  addElements: action('add-elements'),
  removeElements: action('remove-elements'),
  updateElement: action('update-element'),
  delete: action('delete'),
  reorder: action('reorder'),
}
