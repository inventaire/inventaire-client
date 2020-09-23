/* eslint-disable
    import/no-duplicates,
    no-return-assign,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
import filterOutWdEditions from '../filter_out_wd_editions'

export default function () {
  this.childrenClaimProperty = 'wdt:P123'
  this.subentitiesName = 'editions'
  return _.extend(this, specificMethods)
};

var specificMethods = {
  beforeSubEntitiesAdd: filterOutWdEditions,

  initPublisherPublications (refresh) {
    refresh = this.getRefresh(refresh)
    if (!refresh && (this.waitForPublications != null)) { return this.waitForPublications }

    return this.waitForPublications = this.fetchPublisherPublications(refresh)
      .then(this.initPublicationsCollections.bind(this))
  },

  fetchPublisherPublications (refresh) {
    if (!refresh && (this.waitForPublicationsData != null)) { return this.waitForPublicationsData }
    const uri = this.get('uri')
    return this.waitForPublicationsData = _.preq.get(app.API.entities.publisherPublications(uri, refresh))
  },

  initPublicationsCollections (publicationsData) {
    const { collections, editions } = publicationsData
    this.publisherCollectionsUris = _.pluck(collections, 'uri')
    const isolatedEditions = editions.filter(isntInAKnownCollection(this.publisherCollectionsUris))
    return this.isolatedEditionsUris = _.pluck(isolatedEditions, 'uri')
  }
}

var isntInAKnownCollection = collectionsUris => function (edition) {
  if (edition.collection == null) { return true }
  return !collectionsUris.includes(edition.collection)
}
