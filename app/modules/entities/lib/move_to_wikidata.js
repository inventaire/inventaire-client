import { isWikidataItemUri } from '#lib/boolean_tests'
import { i18n, I18n } from '#user/lib/i18n'
import { propertiesEditorsConfigs } from '#entities/lib/properties'
import { unprefixify } from '#lib/wikimedia/wikidata'
import preq from '#lib/preq'

export async function moveToWikidata (invEntityUri) {
  await preq.put(app.API.entities.moveToWikidata, { uri: invEntityUri })
  // Get the refreshed, redirected entity
  // thus also updating entitiesModelsIndexedByUri
  return app.request('get:entity:model', invEntityUri, true)
}

export function checkWikidataMoveabilityStatus (entity) {
  const { uri, type, claims } = entity

  // An entity being created on Inventaire won't have a URI at this point
  if ((uri == null) || isWikidataItemUri(uri)) return { ok: false }

  if (type === 'edition') {
    return {
      ok: false,
      reason: I18n("editions can't be moved to Wikidata for the moment")
    }
  }

  for (const property in claims) {
    const values = claims[property]
    if (propertiesEditorsConfigs[property]?.editorType === 'entity') {
      for (const value of values) {
        if (!isWikidataItemUri(value)) {
          const message = I18n("some values aren't Wikidata entities:")
          return {
            ok: false,
            reason: `${message}: ${i18n(unprefixify(property))} (${property})`
          }
        }
      }
    }
  }

  return {
    ok: true,
    reason: I18n('this entity is ready to be imported to Wikidata')
  }
}
