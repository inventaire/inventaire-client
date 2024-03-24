import { getNonEmptyPropertyClaims } from '#entities/components/editor/lib/editors_helpers'
import preq from '#lib/preq'

export default async function ({ entity }) {
  const publishersUris = getNonEmptyPropertyClaims(entity.claims['wdt:P123'])

  if (!publishersUris) return

  const collectionsUris = await Promise.all(publishersUris.map(getPublisherCollections))
  return _.uniq(collectionsUris.flat())
}

const getPublisherCollections = async publishersUris => {
  const { collections } = await preq.get(app.API.entities.publisherPublications(publishersUris))
  return _.pluck(collections, 'uri')
}
