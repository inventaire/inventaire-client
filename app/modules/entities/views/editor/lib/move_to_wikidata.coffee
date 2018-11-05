module.exports = (invEntityUri)->
  _.preq.put app.API.entities.moveToWikidata, { uri: invEntityUri }
  .then _.Log('RES')
  .then ->
    # Get the refreshed, redirected entity
    # thus also updating entitiesModelsIndexedByUri
    app.request 'get:entity:model', invEntityUri, true
