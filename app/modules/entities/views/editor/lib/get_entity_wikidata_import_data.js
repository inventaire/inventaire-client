# Takes an Inventaire entity URI and a Wikidata entity URI,
# fetches the entities models, and return an object with the labels and claims
# set on the Inventaire entity but not on the Wikidata one to allow importing those

module.exports = (invEntityUri, wdEntityUri)->
  app.request 'get:entities:models',
    uris: [ invEntityUri, wdEntityUri ]
    refresh: true
    index: true
  .then getImportData(invEntityUri, wdEntityUri)

getImportData = (invEntityUri, wdEntityUri)-> (models)->
  invEntity = models[invEntityUri]
  wdEntity = models[wdEntityUri]
  importData = { labels: [], claims: [], invEntity, wdEntity }

  for lang, label of invEntity.get('labels')
    unless wdEntity.get("labels.#{lang}")?
      importData.labels.push { lang, label }

  for property, claims of invEntity.get('claims')
    unless wdEntity.get("claims.#{property}")?
      # Import claims values one by one
      for value in claims
        if _.isEntityUri value
          prefix = value.split(':')[0]
          # Links to Inventaire entities can't be imported to Wikidata
          if prefix is 'wd' then importData.claims.push { property, value }
        else
          importData.claims.push { property, value }

  importData.total = importData.labels.length + importData.claims.length

  return importData
