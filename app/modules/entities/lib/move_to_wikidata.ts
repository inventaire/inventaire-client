import { API } from '#app/api/api'
import app from '#app/app'
import { isWikidataItemUri } from '#app/lib/boolean_tests'
import preq from '#app/lib/preq'
import { unprefixify } from '#app/lib/wikimedia/wikidata'
import { propertiesEditorsConfigs } from '#entities/lib/properties'
import { i18n, I18n } from '#user/lib/i18n'

export async function moveToWikidata (invEntityUri) {
  await preq.put(API.entities.moveToWikidata, { uri: invEntityUri })
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
      reason: I18n("editions can't be moved to Wikidata for the moment"),
    }
  }

  for (const property in claims) {
    const values = claims[property]
    if (propertiesEditorsConfigs[property]?.datatype === 'entity') {
      for (const value of values) {
        if (!isWikidataItemUri(value)) {
          const message = I18n("some values aren't Wikidata entities:")
          return {
            ok: false,
            reason: `${message}: ${i18n(unprefixify(property))} (${property})`,
          }
        }
      }
    }
  }

  return {
    ok: true,
    reason: I18n('this entity is ready to be imported to Wikidata'),
  }
}
