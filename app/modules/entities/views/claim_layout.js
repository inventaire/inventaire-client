import { i18n } from 'modules/user/lib/i18n'
import wd_ from 'lib/wikimedia/wikidata'
import PaginatedEntities from '../collections/paginated_entities'
import EntitiesList from './entities_list'
import GeneralInfobox from './general_infobox'
import entities_ from '../lib/entities'
import { entity as entityValueTemplate } from 'lib/handlebars_helpers/claims_helpers'
import claimLayoutTemplate from './templates/claim_layout.hbs'

export default Marionette.LayoutView.extend({
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

  async onShow () {
    this.waitForModel
    .then(this.ifViewIsIntact('showInfobox'))
    .catch(this.displayError)

    try {
      const uris = await entities_.getReverseClaims(this.property, this.value, this.refresh, true)
      await this.waitForModel
      this.ifViewIsIntact('showEntities', uris)
    } catch (err) {
      this.displayError(err)
    }
  },

  showInfobox () {
    this.infobox.show(new GeneralInfobox({ model: this.model }))
    // Use the URI from the returned entity as it might have been redirected
    const finalClaim = this.property + '-' + this.model.get('uri')
    app.navigate(`entity/${finalClaim}`)
  },

  showEntities (uris) {
    const collection = new PaginatedEntities(null, { uris, defaultType: 'work' })

    // allowlisted properties labels are in i18n keys already, thus should not need
    // to be fetched like what 'entityValueTemplate' is doing for the entity value
    const propertyValue = i18n(wd_.unprefixify(this.property))
    const entityValue = entityValueTemplate(this.value)

    return this.list.show(new EntitiesList({
      title: `${propertyValue}: ${entityValue}`,
      customTitle: true,
      parentModel: this.model,
      childrenClaimProperty: this.property,
      type: 'work',
      collection,
      canAddOne: true,
      standalone: true,
      refresh: this.refresh,
      addButtonLabel: addButtonLabelPerProperty[this.property]
    }))
  }
})

const addButtonLabelPerProperty =
  { 'wdt:P921': 'add a work with this subject' }
