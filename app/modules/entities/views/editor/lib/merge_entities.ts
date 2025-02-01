import { API } from '#app/api/api'
import app from '#app/app'
import { isWikidataItemUri } from '#app/lib/boolean_tests.ts'
import { newError } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import type { EntityUri } from '#server/types/entity'
import getEntityWikidataImportData from './get_entity_wikidata_import_data.ts'

export async function mergeEntities (fromUri: EntityUri, toUri: EntityUri) {
  if (isWikidataItemUri(fromUri) && isWikidataItemUri(toUri)) {
    throw newError('Wikidata entities can not be merged on Inventaire', 400, { fromUri, toUri })
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

async function merge (fromUri: EntityUri, toUri: EntityUri) {
  return preq.put(API.entities.merge, { from: fromUri, to: toUri })
}

async function importEntityDataToWikidata (fromUri: EntityUri, toUri: EntityUri) {
  const importData = await getEntityWikidataImportData(fromUri, toUri)
  log_.info(importData, 'importData')
  // @ts-expect-error
  if (importData.total === 0) {
    log_.info({ fromUri, toUri }, 'no data to import')
  } else {
    // Wikidata entities need per-attribute human validation to import merged data
    return showWikidataDataImporter(importData)
  }
}

async function showWikidataDataImporter (importData) {
  const { default: WikidataDataImporter } = await import('#entities/views/wikidata_data_importer')
  return new Promise((resolve, reject) => {
    app.layout.showChildView('modal', new WikidataDataImporter({ resolve, reject, importData }))
  })
}
