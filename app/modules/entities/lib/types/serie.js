import preq from 'lib/preq'
import commonsSerieWork from './commons_serie_work'

export default function () {
  // Main property by which sub-entities are linked to this one
  this.childrenClaimProperty = 'wdt:P179'

  return _.extend(this, specificMethods)
}

const specificMethods = _.extend({}, commonsSerieWork, {
  fetchPartsData (options = {}) {
    let { refresh } = options
    refresh = this.getRefresh(refresh)
    if (!refresh && (this.waitForPartsData != null)) return this.waitForPartsData

    const uri = this.get('uri')
    this.waitForPartsData = preq.get(app.API.entities.serieParts(uri, refresh))
      .then(res => {
        this.partsData = res.parts
        return this.partsData
      })
    return this.waitForPartsData
  },

  initSerieParts (options) {
    let { refresh, fetchAll } = options
    refresh = this.getRefresh(refresh)
    if (!refresh && this.waitForParts != null) return this.waitForParts

    this.waitForParts = this.fetchPartsData({ refresh })
      .then(initPartsCollections.bind(this, refresh, fetchAll))
      .then(importDataFromParts.bind(this))

    return this.waitForParts
  },

  // Placeholder for cases when a series was formerly identified as a work
  // and got editions or items linking to it, assuming it is a work
  getItemsByCategories () {
    app.execute('report:entity:type:issue', {
      model: this,
      expectedType: 'work',
      context: { module: module.id }
    })
    return Promise.resolve({ personal: [], network: [], public: [] })
  },

  getAllAuthorsUris () {
    const allAuthorsUris = getAuthors(this).concat(...this.parts.map(getAuthors) || [])
    return _.uniq(_.compact(allAuthorsUris))
  },

  async getChildrenCandidatesUris () {
    const { default: getPartsSuggestions } = await import('modules/entities/views/cleanup/lib/get_parts_suggestions')
    const suggestionsCollection = await getPartsSuggestions(this)
    return suggestionsCollection.map(getModelUri)
  }
})

const initPartsCollections = async function (refresh, fetchAll, partsData) {
  const allsPartsUris = _.pluck(partsData, 'uri')
  const partsWithoutSuperparts = partsData.filter(hasNoKnownSuperpart(allsPartsUris))
  const partsWithoutSuperpartsUris = _.pluck(partsWithoutSuperparts, 'uri')

  // Prevent circular dependencies by using a late import
  const { default: PaginatedWorks } = await import('../../collections/paginated_works')

  this.parts = new PaginatedWorks(null, {
    uris: allsPartsUris,
    defaultType: 'work',
    refresh
  })

  this.partsWithoutSuperparts = new PaginatedWorks(null, {
    uris: partsWithoutSuperpartsUris,
    defaultType: 'work',
    refresh,
    parentContext: {
      entityType: 'serie',
      entityUri: this.get('uri')
    }
  })

  if (fetchAll) return this.parts.fetchAll()
}

const hasNoKnownSuperpart = allsPartsUris => function (part) {
  if (part.superpart == null) { return true }
  return !allsPartsUris.includes(part.superpart)
}

const importDataFromParts = function () {
  const firstPartWithPublicationDate = this.parts.find(getPublicationDate)
  if (firstPartWithPublicationDate != null) {
    return this.set('publicationStart', getPublicationDate(firstPartWithPublicationDate))
  }
}

const getModelUri = model => model.get('uri')
const getPublicationDate = model => model.get('claims.wdt:P577.0')
const getAuthors = model => model.getExtendedAuthorsUris()
