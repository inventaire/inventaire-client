import { isInvEntityId } from 'lib/boolean_tests'
import preq from 'lib/preq'
import wdk from 'lib/wikidata-sdk'
import { looksLikeAnIsbn, normalizeIsbn } from 'lib/isbn'

export async function getReverseClaims (property, value, refresh, sort) {
  const { uris } = await preq.get(app.API.entities.reverseClaims(property, value, refresh, sort))
  return uris
}

export function normalizeUri (uri) {
  let [ prefix, id ] = uri.split(':')
  if ((id == null)) {
    if (wdk.isWikidataItemId(prefix)) {
      [ prefix, id ] = [ 'wd', prefix ]
    } else if (isInvEntityId(prefix)) {
      [ prefix, id ] = [ 'inv', prefix ]
    } else if (looksLikeAnIsbn(prefix)) {
      [ prefix, id ] = [ 'isbn', normalizeIsbn(prefix) ]
    }
  } else {
    if (prefix === 'isbn') id = normalizeIsbn(id)
  }

  if (prefix != null && id != null) {
    return `${prefix}:${id}`
  } else {
    return uri
  }
}
