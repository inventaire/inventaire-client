import { isEntityUri, isInvEntityId } from 'lib/boolean_tests'
import wdk from 'lib/wikidata-sdk'
import { looksLikeAnIsbn, normalizeIsbn } from 'lib/isbn'

export default function (text) {
  text = text.trim()
  if (isEntityUri(text)) return text
  if (wdk.isWikidataItemId(text)) return 'wd:' + text
  if (isInvEntityId(text)) return 'inv:' + text
  if (looksLikeAnIsbn(text)) return 'isbn:' + normalizeIsbn(text)
}
