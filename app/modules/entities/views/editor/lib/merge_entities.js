import log_ from 'lib/loggers'
import preq from 'lib/preq'
import WikidataDataImporter from 'modules/entities/views/wikidata_data_importer'
import getEntityWikidataImportData from './get_entity_wikidata_import_data'

export default function (fromUri, toUri) {
  // Invert URIs if the toEntity is a Wikidata entity
  // as we can't request Wikidata entities to merge into inv entities
  if (fromUri.split(':')[0] === 'wd') { [ fromUri, toUri ] = Array.from([ toUri, fromUri ]) }

  // Show the Wikidata data importer only if the user has already set their Wikidata tokens
  // Otherwise, just merge the entity without importing the data
  if ((toUri.split(':')[0] === 'wd') && app.user.hasWikidataOauthTokens()) {
    return importEntityDataToWikidata(fromUri, toUri)
    .then(merge.bind(null, fromUri, toUri))
  } else {
    // Inventaire entities auto-merge their data
    return merge(fromUri, toUri)
  }
};

const merge = (fromUri, toUri) => {
  preq.put(app.API.entities.merge, { from: fromUri, to: toUri })
  // Get the refreshed, redirected entity
  // thus also updating entitiesModelsIndexedByUri
  .then(() => app.request('get:entity:model', fromUri, true))
}

const importEntityDataToWikidata = (fromUri, toUri) => getEntityWikidataImportData(fromUri, toUri)
.then(log_.Info('importData'))
.then(importData => {
  if (importData.total === 0) {
    log_.info({ fromUri, toUri }, 'no data to import')
  } else {
    // Wikidata entities need per-attribute human validation to import merged data
    return showWikidataDataImporter(fromUri, toUri, importData)
  }
})

const showWikidataDataImporter = (fromUri, toUri, importData) => new Promise((resolve, reject) => {
  app.layout.modal.show(new WikidataDataImporter({ resolve, reject, importData }))
})
