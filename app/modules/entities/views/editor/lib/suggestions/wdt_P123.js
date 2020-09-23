{ getReverseClaims } = require 'modules/entities/lib/entities'

module.exports = (entity, index, propertyValuesCount)->
  promises = []
  isbn13h = entity.get 'claims.wdt:P212.0'

  if isbn13h?
    isbnPublisherPrefix = isbn13h.split('-').slice(0, 3).join('-')
    promises.push getReverseClaims('wdt:P3035', isbnPublisherPrefix)

  collectionsUris = entity.get('claims.wdt:P195')
  if collectionsUris? then promises.push getCollectionsPublishers(collectionsUris)

  return Promise.all promises
  .then _.flatten
  .then _.uniq

getCollectionsPublishers = (collectionsUris)->
  app.request 'get:entities:models', { uris: collectionsUris }
  .then (entities)-> _.flatten(entities.map(parseCollectionPublishers))

parseCollectionPublishers = (entity)-> entity.get('claims.wdt:P123')
