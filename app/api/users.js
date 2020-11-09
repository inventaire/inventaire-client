import Commons from './commons'
import endpoint from './endpoint'
const { base, action } = endpoint('users')

const {
  search,
  searchByPosition
} = Commons

export default {
  byIds (ids) { return action('by-ids', { ids: ids.join('|') }) },
  byUsername (username) { return action('by-usernames', { usernames: username }) },
  search: search.bind(null, base),
  searchByPosition: searchByPosition.bind(null, base)
}
