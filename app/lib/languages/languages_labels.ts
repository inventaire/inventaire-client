import { difference, pick, without } from 'underscore'
import { API } from '#app/api/api'
import { isNonEmptyArray } from '#app/lib/boolean_tests'
import { treq } from '#app/lib/preq'
import { capitalize, objectEntries, objectFromEntries, objectKeys } from '#app/lib/utils'
import { getCurrentLang } from '#modules/user/lib/i18n'
import type { GetLanguagesInfoResponse } from '#server/controllers/entities/languages'
import type { TermLanguageCode } from '#server/types/entity'
import { updateLanguagesIndexes } from './languages_indexes'
import type { WikimediaLanguageCode } from 'wikibase-sdk'

type LanguagesLabels = Partial<Record<WikimediaLanguageCode, string>>

const cache: Partial<Record<WikimediaLanguageCode, LanguagesLabels>> = {}

export async function getLanguagesLabels (langs: WikimediaLanguageCode[]): Promise<LanguagesLabels> {
  const preferredLang = getCurrentLang()
  let missingLangs
  if (cache[preferredLang]) {
    missingLangs = difference(langs, objectKeys(cache[preferredLang]))
  } else {
    missingLangs = langs
  }
  await fetchLanguagesInfo(missingLangs)
  return pick(cache[preferredLang], langs)
}

export async function getLanguageLabel (lang: WikimediaLanguageCode) {
  const preferredLang = getCurrentLang()
  return cache[preferredLang]?.[lang] || fetchLanguageInfo(lang)
}

export async function fetchLanguagesInfo (langs: TermLanguageCode[]) {
  const wmLangs = without(langs, 'fromclaims') as WikimediaLanguageCode[]
  if (!isNonEmptyArray(wmLangs)) return {} as LanguagesLabels
  const preferredLang = getCurrentLang()
  const { languages } = await treq.get<GetLanguagesInfoResponse>(API.entities.languages(wmLangs, preferredLang))
  const simplifiedLanguagesInfo = objectFromEntries(objectEntries(languages).map(([ lang, info ]) => {
    return [ lang, capitalize(info.label.value) ]
  }))
  updateLanguagesIndexes(languages)
  cache[preferredLang] ??= {}
  Object.assign(cache[preferredLang], simplifiedLanguagesInfo)
  return simplifiedLanguagesInfo
}

export async function fetchLanguageInfo (lang: WikimediaLanguageCode) {
  const languages = await fetchLanguagesInfo([ lang ])
  return languages[lang]
}
