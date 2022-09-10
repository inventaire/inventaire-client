import { isNonEmptyPlainObject } from '#lib/boolean_tests'

import preq from '#lib/preq'
import sitelinks_ from '#lib/wikimedia/sitelinks'

export async function getWikipediaExtract (entity) {
  const { uri, sitelinks, originalLang } = entity
  if (!uri.startsWith('wd:') || !isNonEmptyPlainObject(sitelinks)) {
    return {}
  }
  const userLang = app.user.lang
  const { title, lang } = sitelinks_.wikipedia(sitelinks, userLang, originalLang)
  return preq.get(app.API.data.wikipediaExtract(lang, title))
}
