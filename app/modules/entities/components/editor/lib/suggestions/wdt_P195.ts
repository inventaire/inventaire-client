import { uniq, pluck } from 'underscore'
import app from '#app/app'
import { getNonEmptyPropertyClaims } from '#entities/components/editor/lib/editors_helpers'
import preq from '#lib/preq'

export default async function ({ entity }) {
  const publishersUris = getNonEmptyPropertyClaims(entity.claims['wdt:P123'])

  if (!publishersUris) return

  const collectionsUris = await Promise.all(publishersUris.map(getPublisherCollections))
  return uniq(collectionsUris.flat())
}

const getPublisherCollections = async publishersUris => {
  const { collections } = await preq.get(app.API.entities.publisherPublications(publishersUris))
  return pluck(collections, 'uri')
}
