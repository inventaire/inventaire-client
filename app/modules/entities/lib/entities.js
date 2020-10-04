import { isInvEntityId } from 'lib/boolean_tests'
import preq from 'lib/preq'
import wdk from 'lib/wikidata-sdk'
import isbn_ from 'lib/isbn'

export default {
  getReverseClaims (property, value, refresh, sort) {
    return preq.get(app.API.entities.reverseClaims(property, value, refresh, sort))
    .get('uris')
  },

  normalizeUri (uri) {
    let [ prefix, id ] = uri.split(':')
    if ((id == null)) {
      if (wdk.isWikidataItemId(prefix)) {
        [ prefix, id ] = [ 'wd', prefix ]
      } else if (isInvEntityId(prefix)) {
        [ prefix, id ] = [ 'inv', prefix ]
      } else if (isbn_.looksLikeAnIsbn(prefix)) {
        [ prefix, id ] = [ 'isbn', isbn_.normalizeIsbn(prefix) ]
      }
    } else {
      if (prefix === 'isbn') { id = isbn_.normalizeIsbn(id) }
    }

    if ((prefix != null) && (id != null)) {
      return `${prefix}:${id}`
    } else { return uri }
  }
}
