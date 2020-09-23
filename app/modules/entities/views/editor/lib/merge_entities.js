WikidataDataImporter = require 'modules/entities/views/wikidata_data_importer'
getEntityWikidataImportData = require './get_entity_wikidata_import_data'

module.exports = (fromUri, toUri)->
  # Invert URIs if the toEntity is a Wikidata entity
  # as we can't request Wikidata entities to merge into inv entities
  if fromUri.split(':')[0] is 'wd' then [ fromUri, toUri ] = [ toUri, fromUri ]

  # Show the Wikidata data importer only if the user has already set their Wikidata tokens
  # Otherwise, just merge the entity without importing the data
  if toUri.split(':')[0] is 'wd' and app.user.hasWikidataOauthTokens()
    importEntityDataToWikidata fromUri, toUri
    .then merge.bind(null, fromUri, toUri)
  else
    # Inventaire entities auto-merge their data
    merge fromUri, toUri

merge = (fromUri, toUri)->
  _.preq.put app.API.entities.merge, { from: fromUri, to: toUri }
  .then ->
    # Get the refreshed, redirected entity
    # thus also updating entitiesModelsIndexedByUri
    app.request 'get:entity:model', fromUri, true

importEntityDataToWikidata = (fromUri, toUri)->
  getEntityWikidataImportData fromUri, toUri
  .then _.Log('importData')
  .then (importData)->
    if importData.total is 0
      _.log { fromUri, toUri }, 'no data to import'
      return
    else
      # Wikidata entities need per-attribute human validation to import merged data
      return showWikidataDataImporter fromUri, toUri, importData

showWikidataDataImporter = (fromUri, toUri, importData)->
  return new Promise (resolve, reject)->
    app.layout.modal.show new WikidataDataImporter { resolve, reject, importData }
