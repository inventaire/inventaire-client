import { pick } from 'underscore'
import { objectEntries } from '#app/lib/utils'
import { getEntitiesAttributesByUris } from '#entities/lib/entities'
import type { LanguagesInfo } from '#server/controllers/entities/languages'
import type { EntityUri, WdEntityUri } from '#server/types/entity'
import { fetchLanguageInfo } from './languages_labels'
import type { WikimediaLanguageCode } from 'wikibase-sdk'

export const wikimediaLanguageCodeByWdUri = {} as Record<EntityUri, WikimediaLanguageCode>
export const WdUriByWikimediaLanguageCode = {} as Record<WikimediaLanguageCode, EntityUri>

export function updateLanguagesIndexes (languagesInfo: LanguagesInfo) {
  for (const [ lang, { uri } ] of objectEntries(languagesInfo)) {
    updateIndexes(uri, lang)
  }
}

function updateIndexes (uri: EntityUri, lang: WikimediaLanguageCode) {
  wikimediaLanguageCodeByWdUri[uri] = lang
  WdUriByWikimediaLanguageCode[lang] = uri
}

export async function getWikimediaLanguageCodesFromWdUris (uris: WdEntityUri[]) {
  const { entities } = await getEntitiesAttributesByUris({ uris, attributes: [ 'claims' ] })
  for (const [ uri, entity ] of objectEntries(entities)) {
    const lang = entity.claims['wdt:P424']?.[0]
    updateIndexes(uri, lang)
  }
  return pick(wikimediaLanguageCodeByWdUri, uris)
}

export async function getWikimediaLanguageCodeFromWdUri (uri: WdEntityUri) {
  if (wikimediaLanguageCodeByWdUri[uri] === undefined) {
    await getWikimediaLanguageCodesFromWdUris([ uri ])
  }
  return wikimediaLanguageCodeByWdUri[uri]
}

export async function getWdUriFromWikimediaLanguageCode (lang: WikimediaLanguageCode) {
  await fetchLanguageInfo(lang)
  return WdUriByWikimediaLanguageCode[lang]
}

export function getCachedWdUriFromWikimediaLanguageCode (lang: WikimediaLanguageCode) {
  return WdUriByWikimediaLanguageCode[lang]
}
