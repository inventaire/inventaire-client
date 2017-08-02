module.exports = (fromUri, toUri)->
  # Invert URIs if the toEntity is a Wikidata entity
  # as we can't request Wikidata entities to merge into inv entities
  if fromUri.split(':')[0] is 'wd' then [ fromUri, toUri ] = [ toUri, fromUri ]

  _.preq.put app.API.entities.merge,
    from: fromUri
    to: toUri
  .then ->
    # Get the refreshed, redirected entity
    # thus also updating entitiesModelsIndexedByUri
    app.request 'get:entity:model', fromUri, true
