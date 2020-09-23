import { getReverseClaims } from 'modules/entities/lib/entities'

export default function (entity, index, propertyValuesCount) {
  const promises = []
  const isbn13h = entity.get('claims.wdt:P212.0')

  if (isbn13h != null) {
    const isbnPublisherPrefix = isbn13h.split('-').slice(0, 3).join('-')
    promises.push(getReverseClaims('wdt:P3035', isbnPublisherPrefix))
  }

  const collectionsUris = entity.get('claims.wdt:P195')
  if (collectionsUris != null) { promises.push(getCollectionsPublishers(collectionsUris)) }

  return Promise.all(promises)
  .then(_.flatten)
  .then(_.uniq)
};

var getCollectionsPublishers = collectionsUris => app.request('get:entities:models', { uris: collectionsUris })
.then(entities => _.flatten(entities.map(parseCollectionPublishers)))

var parseCollectionPublishers = entity => entity.get('claims.wdt:P123')
