import { uniq, flatten } from 'underscore'
import app from '#app/app'
import { getNonEmptyPropertyClaims } from '#entities/components/editor/lib/editors_helpers'
import { getReverseClaims } from '#entities/lib/entities'

export default async function ({ entity }) {
  const promises = []
  const isbn13h = entity.claims['wdt:P212']?.[0]

  if (isbn13h != null) {
    const isbnPublisherPrefix = isbn13h.split('-').slice(0, 3).join('-')
    promises.push(getReverseClaims('wdt:P3035', isbnPublisherPrefix))
  }

  const collectionsUris = getNonEmptyPropertyClaims(entity.claims['wdt:P195'])
  if (collectionsUris.length > 0) {
    promises.push(getCollectionsPublishers(collectionsUris))
  }

  return Promise.all(promises)
  .then(flatten)
  .then(uniq)
}

const getCollectionsPublishers = async collectionsUris => {
  const entities = await app.request('get:entities:models', { uris: collectionsUris })
  return flatten(entities.map(parseCollectionPublishers))
}

const parseCollectionPublishers = entity => entity.claims['wdt:P123']
