import { pluck } from 'underscore'
import preq from '#lib/preq'
import filterOutWdEditions from '../filter_out_wd_editions.ts'

export default function () {
  this.childrenClaimProperty = 'wdt:P123'
  this.subentitiesName = 'editions'
  return Object.assign(this, specificMethods)
}

const specificMethods = {
  beforeSubEntitiesAdd: filterOutWdEditions,

  initPublisherPublications (refresh) {
    refresh = this.getRefresh(refresh)
    if (!refresh && this.waitForPublications != null) return this.waitForPublications

    this.waitForPublications = this.fetchPublisherPublications(refresh)
      .then(this.initPublicationsCollections.bind(this))

    return this.waitForPublications
  },

  fetchPublisherPublications (refresh) {
    if (!refresh && this.waitForPublicationsData != null) return this.waitForPublicationsData
    const uri = this.get('uri')
    this.waitForPublicationsData = preq.get(app.API.entities.publisherPublications(uri, refresh))
    return this.waitForPublicationsData
  },

  initPublicationsCollections (publicationsData) {
    const { collections, editions } = publicationsData
    this.publisherCollectionsUris = pluck(collections, 'uri')
    const isolatedEditions = editions.filter(isntInAKnownCollection(this.publisherCollectionsUris))
    this.isolatedEditionsUris = pluck(isolatedEditions, 'uri')
  },
}

const isntInAKnownCollection = collectionsUris => function (edition) {
  if (edition.collection == null) return true
  return !collectionsUris.includes(edition.collection)
}
