import { unprefixify } from '#lib/wikimedia/wikidata'
import wdLang from 'wikidata-lang'
import getEntityItemsByCategories from '../get_entity_items_by_categories.js'
import error_ from '#lib/error'
import { partition } from 'underscore'
const farInTheFuture = '2100'

export default function () {
  _.extend(this, specificMethods)
  this.setClaimsBasedAttributes()

  // Editions don't have subentities so the list of all their uris,
  // including their subentities, are limited to their own uri
  this.set('allUris', [ this.get('uri') ])

  this.initWorksRelations()
}

const specificMethods = {
  setLang () {
    const langUri = this.get('claims.wdt:P407.0')
    const lang = langUri ? wdLang.byWdId[unprefixify(langUri)]?.code : undefined
    this.set('lang', lang)
  },

  setLabelFromTitle () {
    // Take the label from the monolingual title property
    this.set('label', this.get('claims.wdt:P1476.0'))
  },

  setPublicationTime () {
    const publicationDate = this.get('claims.wdt:P577.0')
    const publicationTime = new Date(publicationDate || farInTheFuture).getTime()
    this.set('publicationTime', publicationTime)
  },

  setClaimsBasedAttributes () {
    this.setLang()
    this.setLabelFromTitle()
    this.setPublicationTime()
    this.set('isCompositeEdition', (this.get('claims.wdt:P629')?.length > 1))
  },

  onClaimsChange (property, oldValue, newValue) {
    this.setClaimsBasedAttributes()
    if (property === 'wdt:P629') this.initWorksRelations()
  },

  getItemsByCategories: getEntityItemsByCategories,

  async initWorksRelations () {
    // Works is pluralized to account for composite editions
    // cf https://github.com/inventaire/inventaire/issues/93
    const worksUris = this.get('claims.wdt:P629')

    if (worksUris != null) {
      this.waitForWorks = this._getWorks(worksUris)
    } else {
      if (!this.creating) {
        const uri = this.get('uri')
        error_.report('edition entity misses associated works (wdt:P629)', { edition: uri })
      }
      this.works = []
      startListeningForClaimsChanges.call(this)
      this.waitForWorks = Promise.resolve()
    }
  },

  async _getWorks (worksUris) {
    let works = await this.reqGrab('get:entities:models', { uris: worksUris }, 'works')
    // Filter-out entities that are not typed as works. Typically editions wrongly used as P629 values in Wikidata,
    // or Wikidata works that have had their P31 changed to be an edition
    const [ confirmedWorks, nonWorks ] = partition(works, isWorkModel)
    works = confirmedWorks
    if (nonWorks.length > 0) {
      const nonWorksUris = nonWorks.map(entity => entity.get('uri'))
      error_.report('non-works entities used as P629', { edition: this.get('uri'), nonWorksUris })
    }
    inheritData.call(this, works)
    // Got to be initialized after inheritData is run to avoid running
    // several times at initialization
    startListeningForClaimsChanges.call(this)
    return works
  },

  // Editions don't have subentities
  async fetchSubEntities () {}
}

const isWorkModel = workModel => workModel.get('type') === 'work'

// Editions inherit some claims from their work but not all, as it could get confusing.
// Ex: publication date should not be inherited
const inheritData = function (works) {
  // Do not set inherited claims when creating, as they would be sent as part of the claims
  // of the new entity, and rejected
  if (this.creating) return
  // Use cases: used on the edition layout to display authors and series
  setWorksClaims.call(this, works, 'wdt:P50')
  setWorksClaims.call(this, works, 'wdt:P58')
  setWorksClaims.call(this, works, 'wdt:P110')
  setWorksClaims.call(this, works, 'wdt:P6338')
  setWorksClaims.call(this, works, 'wdt:P179')
}

const setWorksClaims = function (works, property) {
  const values = _.chain(works)
    .map(work => work.get(`claims.${property}`))
    .flatten()
    .compact()
    .uniq()
    .value()
  if (values.length > 0) this.set(`claims.${property}`, values)
}

const startListeningForClaimsChanges = function () {
  this.on('change:claims', this.onClaimsChange.bind(this))
  // Do no return the event listener return value as it was making Bluebird crash
  // (at least when passed to a .then)
}
