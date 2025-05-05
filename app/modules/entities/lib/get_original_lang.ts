import { pick } from 'underscore'
import { getWikimediaLanguageCodeFromWdUri } from '#app/lib/languages/languages_indexes'
import { pickOne, objLength } from '#app/lib/utils'
import type { SerializedEntity } from './entities'

const langProperties = [
  'wdt:P103', // native language
  'wdt:P407', // language of work
  'wdt:P1412', // languages spoken, written or signed
  'wdt:P2439', // language (general)
]

export async function getOriginalLang (claims: SerializedEntity['claims']) {
  const langClaims = pick(claims, langProperties)
  if (objLength(langClaims) === 0) return

  const originalLangUri = pickOne(langClaims)?.[0]
  if (originalLangUri != null) {
    return getWikimediaLanguageCodeFromWdUri(originalLangUri)
  }
}
