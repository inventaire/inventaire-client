/* eslint-disable
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
const { base, action } = require('./endpoint')('shelves')

export default {
  base,
  byId (id) { return action('by-ids', { ids: id, 'with-items': true }) },
  byIds (ids) {
    ids = _.forceArray(ids).join('|')
    return action('by-ids', { ids, 'with-items': true })
  },
  byOwners (id) { return action('by-owners', { owners: id }) },
  addItems: action('add-items'),
  removeItems: action('remove-items'),
  create: action('create'),
  update: action('update'),
  delete: action('delete')
}
