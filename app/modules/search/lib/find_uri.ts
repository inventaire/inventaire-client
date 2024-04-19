import { isInvEntityId } from '#app/lib/boolean_tests'
import { looksLikeAnIsbn, normalizeIsbn } from '#app/lib/isbn'

export default function (text) {
  text = text.trim()
  if (isWikidataId.test(text)) text = 'wd:' + text
  if (caseInsensitiveEntityUri.test(text)) return text.replace('wd:q', 'wd:Q')
  if (isInvEntityId(text)) return 'inv:' + text
  if (looksLikeAnIsbn(text)) return 'isbn:' + normalizeIsbn(text)
}

const caseInsensitiveEntityUri = /^(wd:[Qq][1-9]\d*|inv:[0-9a-f]{32}|isbn:\w{10}(\w{3})?)$/

const isWikidataId = /^[Qq][1-9]\d*/
