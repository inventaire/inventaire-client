import { getReverseClaims } from '#entities/lib/entities'

export default function ({ entity }) {
  const promises = []
  const isbn13h = entity.claims['wdt:P212']?.[0]

  if (isbn13h != null) {
    const isbnPublisherPrefix = isbn13h.split('-').slice(0, 3).join('-')
    promises.push(getReverseClaims('wdt:P3035', isbnPublisherPrefix))
  }

  const collectionsUris = entity.claims['wdt:P195']
  if (collectionsUris != null) {
    promises.push(getCollectionsPublishers(collectionsUris))
  }

  return Promise.all(promises)
  .then(_.flatten)
  .then(_.uniq)
}

const getCollectionsPublishers = async collectionsUris => {
  const entities = await app.request('get:entities:models', { uris: collectionsUris })
  return _.flatten(entities.map(parseCollectionPublishers))
}

const parseCollectionPublishers = entity => entity.claims['wdt:P123']
