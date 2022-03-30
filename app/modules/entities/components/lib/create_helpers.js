import propertiesPerType from '#entities/lib/editor/properties_per_type'
import { typeHasName } from '#entities/lib/types/entities_types'
import { i18n } from '#user/lib/i18n'
import wdLang from 'wikidata-lang'
import preq from '#lib/preq'
import assert_ from '#lib/assert_types'

export function getMissingRequiredProperties ({ entity, requiredProperties, requiresLabel }) {
  const { type } = entity
  assert_.string(type)
  const missingRequiredProperties = []
  if (requiresLabel) {
    if (Object.keys(entity.labels).length <= 0) {
      if (typeHasName(type)) {
        missingRequiredProperties.push(i18n('name'))
      } else {
        missingRequiredProperties.push(i18n('title'))
      }
    }
  }
  for (const property of requiredProperties) {
    const propertyClaims = _.compact(entity.claims[property])
    if (propertyClaims.length <= 0) {
      const labelKey = propertiesPerType[type][property].customLabel || property
      missingRequiredProperties.push(i18n(labelKey))
    }
  }
  return missingRequiredProperties
}

export async function createEditionAndWorkFromEntry ({ edition, work }) {
  const title = edition.claims['wdt:P1476'][0]
  const titleLang = edition.claims['wdt:P407'][0]
  const workLabelLangCode = wdLang.byWdId[titleLang]?.code || 'en'
  work.labels = { [workLabelLangCode]: title }
  const entry = {
    edition,
    works: [ work ]
  }
  const { entries } = await preq.post(app.API.entities.resolve, {
    entries: [ entry ],
    update: true,
    create: true,
    enrich: true
  })
  const { uri } = entries[0].edition
  return uri
}
