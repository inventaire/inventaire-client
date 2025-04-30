import { without } from 'underscore'
import { API } from '#app/api/api'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import { treq } from '#app/lib/preq'
import { objectEntries, objectFromEntries } from '#app/lib/utils'
import { getCurrentLang } from '#modules/user/lib/i18n'
import type { GetLanguagesInfoResponse } from '#server/controllers/entities/languages'
import type { TermLanguageCode } from '#server/types/entity'
import type { WikimediaLanguageCode } from 'wikibase-sdk'

type LanguagesLabels = Partial<Record<WikimediaLanguageCode, string>>

const cache: Partial<Record<WikimediaLanguageCode, LanguagesLabels>> = {}

export async function getLanguageLabel (lang: WikimediaLanguageCode) {
  const preferredLang = getCurrentLang()
  return cache[preferredLang]?.[lang] || fetchLanguageLabel(lang)
}

export async function fetchLanguagesLabels (langs: TermLanguageCode[]) {
  const wmLangs = without(langs, 'fromclaims') as WikimediaLanguageCode[]
  if (!isNonEmptyArray(wmLangs)) return {} as LanguagesLabels
  const preferredLang = getCurrentLang()
  const { languages } = await treq.get<GetLanguagesInfoResponse>(API.entities.languages(wmLangs, preferredLang))
  const simplifiedLanguagesInfo = objectFromEntries(objectEntries(languages).map(([ lang, info ]) => {
    return [ lang, info.label.value ]
  }))
  cache[preferredLang] ??= {}
  Object.assign(cache[preferredLang], simplifiedLanguagesInfo)
  return simplifiedLanguagesInfo
}

async function fetchLanguageLabel (lang: WikimediaLanguageCode) {
  const languages = await fetchLanguagesLabels([ lang ])
  return languages[lang]
}
