/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import { buildPath } from 'lib/location'
const { base } = require('./endpoint')('search')

export default function (types, search, limit = 10) {
  const { lang } = app.user
  types = _.forceArray(types).join('|')
  search = encodeURIComponent(search)
  return buildPath(base, { types, search, lang, limit })
};
