module.exports = (invEntityUri, asP31value)->
  _.preq.put app.API.entities.moveToWikidata, { uri: invEntityUri, asP31value }
  .then _.Log('RES')
  .then ->
    # Get the refreshed, redirected entity
    # thus also updating entitiesModelsIndexedByUri
    app.request 'get:entity:model', invEntityUri, true
