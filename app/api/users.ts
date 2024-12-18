import { uniq } from 'underscore'
import type { UserAccountUri } from '#server/types/server'
import Commons from './commons.ts'
import { getEndpointPathBuilders } from './endpoint.ts'

const { base, action } = getEndpointPathBuilders('users')

const {
  search,
  searchByPosition,
} = Commons

export default {
  byIds (ids) { return action('by-ids', { ids: uniq(ids).join('|') }) },
  byUsername (username) { return action('by-usernames', { usernames: username }) },
  byAccts (accts: UserAccountUri[]) { return action('by-accts', { accts: accts.join('|') }) },
  search: search.bind(null, base),
  searchByPosition: searchByPosition.bind(null, base),
  byCreationDate (params: { limit: number, offset: number, filter?: string }) {
    const { limit, offset, filter } = params
    return action('by-creation-date', { limit, offset, filter })
  },
}
