module.exports = (fromUri, toUri)->
  # _.preq.put app.API.entities.merge,
  _.preq.put app.API.entities.merge,
    from: fromUri
    to: toUri
  .then ->
    # Get the refreshed, redirected entity
    # thus also updating entitiesModelsIndexedByUri
    app.request 'get:entity:model', fromUri, true
