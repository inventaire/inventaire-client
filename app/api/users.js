/* eslint-disable
    import/no-duplicates,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import Commons from './commons'
const { base, action } = require('./endpoint')('users')

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
