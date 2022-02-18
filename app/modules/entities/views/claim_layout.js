import { i18n } from '#modules/user/lib/i18n'
import { unprefixify } from '#lib/wikimedia/wikidata'
import PaginatedEntities from '../collections/paginated_entities.js'
import getEntitiesListView from './entities_list.js'
import GeneralInfobox from './general_infobox.js'
import { getReverseClaims } from '../lib/entities.js'
import { entity as entityValueTemplate } from '#lib/handlebars_helpers/claims_helpers'
import claimLayoutTemplate from './templates/claim_layout.hbs'
import '../scss/claim_layout.scss'

export default Marionette.View.extend({
  id: 'claimLayout',
  template: claimLayoutTemplate,
  regions: {
    infobox: '.infobox',
    list: '.list'
  },

  initialize () {
    ({ property: this.property, value: this.value, refresh: this.refresh } = this.options)

    this.waitForModel = app.request('get:entity:model', this.value, this.refresh)
      .then(model => { this.model = model })
  },

  async onRender () {
    this.waitForModel
    .then(this.ifViewIsIntact('showInfobox'))
    .catch(this.displayError)

    try {
      const uris = await getReverseClaims(this.property, this.value, this.refresh, true)
      await this.waitForModel
      if (this.isIntact()) this.showEntities(uris)
    } catch (err) {
      this.displayError(err)
    }
  },

  showInfobox () {
    this.showChildView('infobox', new GeneralInfobox({ model: this.model }))
    // Use the URI from the returned entity as it might have been redirected
    const finalClaim = this.property + '-' + this.model.get('uri')
    app.navigate(`entity/${finalClaim}`)
  },

  async showEntities (uris) {
    const collection = new PaginatedEntities(null, { uris, defaultType: 'work' })

    // allowlisted properties labels are in i18n keys already, thus should not need
    // to be fetched like what 'entityValueTemplate' is doing for the entity value
    const propertyValue = i18n(unprefixify(this.property))
    const entityValue = entityValueTemplate(this.value)

    const view = await getEntitiesListView({
      title: `${propertyValue}: ${entityValue}`,
      customTitle: true,
      parentModel: this.model,
      childrenClaimProperty: this.property,
      type: 'work',
      collection,
      canAddOne: true,
      canSearchListCandidatesFromLabel: canSearchListCandidatesFromLabel.includes(this.property),
      standalone: true,
      refresh: this.refresh,
      addButtonLabel: addButtonLabelPerProperty[this.property]
    })

    this.showChildView('list', view)
  }
})

const addButtonLabelPerProperty = {
  'wdt:P921': 'add a work with this subject'
}

const canSearchListCandidatesFromLabel = [
  'wdt:P921'
]
