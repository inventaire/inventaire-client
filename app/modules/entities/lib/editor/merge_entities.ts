import { API } from '#app/api/api'
import { appLayout } from '#app/init_app_layout'
import { isWikidataItemUri } from '#app/lib/boolean_tests'
import { newError } from '#app/lib/error'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { getInvEntityImportableData, type InvEntityImportableData } from '#entities/lib/get_entity_wikidata_import_data'
import type { EntityUri, WdEntityUri } from '#server/types/entity'

export async function mergeEntities (fromUri: EntityUri, toUri: EntityUri) {
  if (isWikidataItemUri(fromUri) && isWikidataItemUri(toUri)) {
    throw newError('Wikidata entities can not be merged on Inventaire', 400, { fromUri, toUri })
  }
  // Invert URIs if the toEntity is a Wikidata entity
  // as we can't request Wikidata entities to merge into inv entities
  if (isWikidataItemUri(fromUri)) [ fromUri, toUri ] = [ toUri, fromUri ]

  if (toUri.split(':')[0] === 'wd') {
    await importEntityDataToWikidata(fromUri, toUri as WdEntityUri)
    return merge(fromUri, toUri)
  } else {
    // Inventaire entities auto-merge their data
    return merge(fromUri, toUri)
  }
}

async function merge (fromUri: EntityUri, toUri: EntityUri) {
  return preq.put(API.entities.merge, { from: fromUri, to: toUri })
}

async function importEntityDataToWikidata (fromUri: EntityUri, toUri: WdEntityUri) {
  const importData = await getInvEntityImportableData(fromUri, toUri)
  log_.info(importData, 'importData')
  if (importData.total === 0) {
    log_.info({ fromUri, toUri }, 'no data to import')
  } else {
    // Wikidata entities need per-attribute human validation to import merged data
    return showWikidataDataImporter(importData)
  }
}

async function showWikidataDataImporter (importData: InvEntityImportableData) {
  const { default: WikidataDataImporter } = await import('#entities/components/wikidata_data_importer.svelte')
  return new Promise(resolve => {
    appLayout.showChildComponent('modal', WikidataDataImporter, {
      props: {
        resolve,
        importData,
      },
    })
  })
}
