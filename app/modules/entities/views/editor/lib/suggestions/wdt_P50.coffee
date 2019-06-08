module.exports = (entity, index, propertyValuesCount)->
  serieUri = entity.get 'claims.wdt:P179.0'
  unless serieUri? then return

  app.request 'get:entity:model', serieUri
  .then (serie)-> serie.getExtendedAuthorsUris()
