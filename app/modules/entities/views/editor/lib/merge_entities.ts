import { isWikidataItemUri } from '#lib/boolean_tests.js'
import log_ from '#lib/loggers'
import preq from '#lib/preq'
import error_ from '#lib/error'
import getEntityWikidataImportData from './get_entity_wikidata_import_data.js'

export default async function (fromUri, toUri) {
  if (isWikidataItemUri(fromUri) && isWikidataItemUri(toUri)) {
    throw error_.new('Wikidata entities can not be merged on Inventaire', 400, { fromUri, toUri })
  }
  // Invert URIs if the toEntity is a Wikidata entity
  // as we can't request Wikidata entities to merge into inv entities
  if (isWikidataItemUri(fromUri)) [ fromUri, toUri ] = [ toUri, fromUri ]

  // Show the Wikidata data importer only if the user has already set their Wikidata tokens
  // Otherwise, just merge the entity without importing the data
  if ((toUri.split(':')[0] === 'wd') && app.user.hasWikidataOauthTokens()) {
    await importEntityDataToWikidata(fromUri, toUri)
    return merge(fromUri, toUri)
  } else {
    // Inventaire entities auto-merge their data
    return merge(fromUri, toUri)
  }
}

const merge = async (fromUri, toUri) => {
  await preq.put(app.API.entities.merge, { from: fromUri, to: toUri })
  // Get the refreshed, redirected entity
  // thus also updating entitiesModelsIndexedByUri
  return app.request('get:entity:model', fromUri, true)
}

const importEntityDataToWikidata = async (fromUri, toUri) => {
  const importData = await getEntityWikidataImportData(fromUri, toUri)
  log_.info(importData, 'importData')
  if (importData.total === 0) {
    log_.info({ fromUri, toUri }, 'no data to import')
  } else {
    // Wikidata entities need per-attribute human validation to import merged data
    return showWikidataDataImporter(importData)
  }
}

const showWikidataDataImporter = async importData => {
  const { default: WikidataDataImporter } = await import('#entities/views/wikidata_data_importer')
  return new Promise((resolve, reject) => {
    app.layout.showChildView('modal', new WikidataDataImporter({ resolve, reject, importData }))
  })
}
