import { uniq, flatten } from 'underscore'
import { getNonEmptyPropertyClaims } from '#entities/components/editor/lib/editors_helpers'
import { getReverseClaims, getCollectionsPublishers } from '#entities/lib/entities'

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
