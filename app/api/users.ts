import { uniq } from 'underscore'
import Commons from './commons.ts'
import endpoint from './endpoint.ts'

const { base, action } = endpoint('users')

const {
  search,
  searchByPosition,
} = Commons

export default {
  byIds (ids) { return action('by-ids', { ids: uniq(ids).join('|') }) },
  byUsername (username) { return action('by-usernames', { usernames: username }) },
  search: search.bind(null, base),
  searchByPosition: searchByPosition.bind(null, base),
  byCreationDate (params = {}) {
    const { limit, offset } = params
    return action('by-creation-date', { limit, offset })
  },
}
