import { uniq } from 'underscore'
import { isNonEmptyString } from '#app/lib/boolean_tests'
import type { SingleValueTermsWithInferredValues } from '#server/types/entity'
import type { WikimediaLanguageCode } from 'wikibase-sdk'

export function getBestLangValue (lang: WikimediaLanguageCode, originalLang: WikimediaLanguageCode, data?: SingleValueTermsWithInferredValues) {
  if (!data) return {}

  const order = getLangPriorityOrder(lang, originalLang, data)

  while (order.length > 0) {
    const nextLang = order.shift()
    let value = data[nextLang]
    if (value instanceof Array) {
      value = value[0]
    }
    if (isNonEmptyString(value)) {
      return { value, lang: nextLang }
    }
  }

  return {}
}

const getLangPriorityOrder = function (lang, originalLang, data) {
  const order = [ lang ]
  if (originalLang != null) order.push(originalLang)
  order.push('en')
  const availableLangs = Object.keys(data)
  return uniq(order.concat(availableLangs))
}
