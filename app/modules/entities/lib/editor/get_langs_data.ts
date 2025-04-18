import { uniq } from 'underscore'
import wdLang from 'wikidata-lang'
import availableLangList from '#app/lib/available_lang_list'
import { langs as activeLangs } from '#app/lib/languages'
import { getCurrentLang } from '#modules/user/lib/i18n'
import type { WdEntityUri } from '#server/types/entity'

export function getLangsData (selectedLang, labels) {
  const availableLangs = Object.keys(labels)
  const highPriorityLangs = [ getCurrentLang(), 'en' ]
  const allLangs = uniq(availableLangs.concat(highPriorityLangs, activeLangs))
  // No distinction is made between available langs and others
  // as we can't style the <option> element anyway
  return availableLangList(allLangs, selectedLang)
}

export function getLangUri (lang: string) {
  if (wdLang.byCode[lang]) {
    const wdId = wdLang.byCode[lang].wd
    return `wd:${wdId}` as WdEntityUri
  }
}
