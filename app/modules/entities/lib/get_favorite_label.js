import { propertiesPerType } from '#entities/lib/editor/properties_per_type'
import getBestLangValue from '#entities/lib/get_best_lang_value'

export default function (entity) {
  const { type, labels } = entity
  const typeProperties = propertiesPerType[type]
  const hasMonolingualTitle = typeProperties['wdt:P1476'] != null

  let favoriteLabel
  if (hasMonolingualTitle) {
    favoriteLabel = entity.claims['wdt:P1476']?.[0]
  } else {
    favoriteLabel = getBestLangValue(app.user.lang, null, labels).value
  }
  return favoriteLabel
}
