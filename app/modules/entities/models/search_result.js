import { isInvEntityId } from '#lib/boolean_tests'
import Filterable from '#modules/general/models/filterable'
import getBestLangValue from '#modules/entities/lib/get_best_lang_value'
import wdk from '#lib/wikidata-sdk'
import error_ from '#lib/error'

// make models use 'id' as idAttribute so that search results
// automatically deduplicate themselves
export default Filterable.extend({
  idAttribute: 'id',
  initialize () {
    const { lang } = app.user

    const [ label, labels, descriptions ] = this.gets('label', 'labels', 'descriptions')

    if ((label == null) && (labels != null)) {
      this.set('label', getBestLangValue(lang, null, labels).value)
    }

    if (descriptions != null) {
      this.set('description', getBestLangValue(lang, null, descriptions).value)
    }

    const [ prefix ] = getPrefix(this.id)

    if (prefix === 'wd') this._wikidataInit()
    else if (prefix === 'inv') this._invInit()
  },

  _wikidataInit () {
    this.set({
      uri: `wd:${this.id}`,
      url: `https://wikidata.org/entity/${this.id}`
    })
  },

  _invInit () {
    this.set({
      uri: `inv:${this.id}`,
      url: `/entity/${this.id}`
    })
  },

  matchable () {
    if (this._values != null) return this._values
    const labels = getValues(this.get('labels'))
    const descriptions = getValues(this.get('descriptions'))
    const aliases = _.flatten(getValues(this.get('aliases')))
    const uris = [ this.id, this.get('uri') ]
    this._values = [ this.id ].concat(labels, aliases, descriptions, uris)
    return this._values
  }
})

const getValues = obj => obj != null ? _.values(obj) : []

// Search results arrive as either Wikidata or inventaire documents
// with ids unprefixed. The solutions to fix it:
// * formatting search documents to include prefixes
// * guessing which source the document belongs too from what we get
// For the moment, let's keep it easy and use the 2nd solution
const getPrefix = function (id) {
  if (wdk.isWikidataItemId(id)) {
    return [ 'wd', id ]
  } else if (isInvEntityId(id)) {
    return [ 'inv', id ]
  } else {
    throw error_.new('unknown id domain', { id })
  }
}
