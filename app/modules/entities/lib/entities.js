/* eslint-disable
    import/no-duplicates,
    no-undef,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import wdk from 'lib/wikidata-sdk'
import isbn_ from 'lib/isbn'

export default {
  getReverseClaims (property, value, refresh, sort) {
    return _.preq.get(app.API.entities.reverseClaims(property, value, refresh, sort))
    .get('uris')
  },

  normalizeUri (uri) {
    let [ prefix, id ] = Array.from(uri.split(':'))
    if ((id == null)) {
      if (wdk.isWikidataItemId(prefix)) {
        [ prefix, id ] = Array.from([ 'wd', prefix ])
      } else if (_.isInvEntityId(prefix)) {
        [ prefix, id ] = Array.from([ 'inv', prefix ])
      } else if (isbn_.looksLikeAnIsbn(prefix)) {
        [ prefix, id ] = Array.from([ 'isbn', isbn_.normalizeIsbn(prefix) ])
      }
    } else {
      if (prefix === 'isbn') { id = isbn_.normalizeIsbn(id) }
    }

    if ((prefix != null) && (id != null)) {
      return `${prefix}:${id}`
    } else { return uri }
  }
}
