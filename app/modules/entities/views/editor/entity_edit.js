import { I18n, i18n } from 'modules/user/lib/i18n'
import LabelsEditor from './labels_editor'
import PropertiesEditor from './properties_editor'
import propertiesCollection from '../../lib/editor/properties_collection'
import AdminSection from './admin_section'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'
import properties from 'modules/entities/lib/properties'
import { unprefixify } from 'lib/wikimedia/wikidata'
import moveToWikidata from './lib/move_to_wikidata'
import { startLoading } from 'modules/general/plugins/behaviors'
import propertiesPerType from 'modules/entities/lib/editor/properties_per_type'
import entityEditTemplate from './templates/entity_edit.hbs'
import 'modules/entities/scss/entity_edit.scss'

const typesWithoutLabel = [
  'edition',
  'collection'
]
// Keep in sync with server/controllers/entities/lib/validate_critical_claims.js
const requiredPropertyPerType = {
  edition: [ 'wdt:P629', 'wdt:P1476' ],
  collection: [ 'wdt:P1476', 'wdt:P123' ]
}

export default Marionette.LayoutView.extend({
  id: 'entityEdit',
  template: entityEditTemplate,
  behaviors: {
    AlertBox: {},
    Loading: {},
    PreventDefault: {}
  },

  regions: {
    title: '.title',
    claims: '.claims',
    admin: '.admin'
  },

  ui: {
    navigationButtons: '.navigationButtons',
    missingDataMessage: '.missingDataMessage'
  },

  initialize () {
    this.creationMode = this.model.creating
    this.requiresLabel = !typesWithoutLabel.includes(this.model.type)
    this.requiredProperties = requiredPropertyPerType[this.model.type] || []
    this.canBeAddedToInventory = inventoryTypes.includes(this.model.type)
    this.showAdminSection = app.user.hasDataadminAccess && !this.creationMode

    if (this.creationMode) {
      this.setMissingRequiredProperties()
    }

    if (this.model.subEntitiesInverseProperty != null) {
      this.waitForPropCollection = this.model.fetchSubEntities()
        .then(this.initPropertiesCollections.bind(this))
    } else {
      this.initPropertiesCollections()
      this.waitForPropCollection = Promise.resolve()
    }

    this.navigationButtonsDisabled = false
  },

  initPropertiesCollections () { this.properties = propertiesCollection(this.model) },

  onShow () {
    if (this.requiresLabel) {
      this.title.show(new LabelsEditor({ model: this.model }))
    }

    if (this.showAdminSection) {
      this.admin.show(new AdminSection({ model: this.model }))
    }

    this.waitForPropCollection
    .then(this.showPropertiesEditor.bind(this))

    this.listenTo(this.model, 'change', this.updateNavigationButtons.bind(this))
    this.updateNavigationButtons()
  },

  showPropertiesEditor () {
    return this.claims.show(new PropertiesEditor({
      collection: this.properties,
      propertiesShortlist: this.model.propertiesShortlist
    }))
  },

  serializeData () {
    const attrs = this.model.toJSON()
    attrs.creationMode = this.creationMode
    const typePossessive = possessives[attrs.type]
    attrs.createAndShowLabel = `create and go to the ${typePossessive} page`
    attrs.returnLabel = `return to the ${typePossessive} page`
    attrs.creating = this.model.creating
    attrs.canCancel = this.canCancel()
    attrs.moveToWikidata = this.moveToWikidataData()
    // Do not show the signal data error button in creation mode
    // as it wouldn't make sense
    attrs.signalDataErrorButton = !this.creationMode
    // Used when ItemShowLayout attempts to 'preciseEdition' with a new edition
    attrs.itemToUpdate = this.itemToUpdate
    attrs.canBeAddedToInventory = this.canBeAddedToInventory
    attrs.missingRequiredProperties = this.missingRequiredProperties
    return attrs
  },

  events: {
    'click .entity-edit-cancel': 'cancel',
    'click .createAndShowEntity': 'createAndShowEntity',
    'click .createAndAddEntity': 'createAndAddEntity',
    'click .createAndUpdateItem': 'createAndUpdateItem',
    'click #signalDataError': 'signalDataError',
    'click #moveToWikidata': 'moveToWikidata'
  },

  canCancel () {
    // In the case of an entity being created, showing the entity page would fail
    if (!this.model.creating) return true
    // Don't display a cancel button if we don't know where to redirect
    return Backbone.history.last.length > 0
  },

  cancel () {
    const fallback = () => app.execute('show:entity:from:model', this.model)
    app.execute('history:back', { fallback })
  },

  createAndShowEntity () {
    return this._createAndAction(app.Execute('show:entity:from:model'))
  },

  createAndAddEntity () {
    return this._createAndAction(app.Execute('show:entity:add:from:model'))
  },

  createAndUpdateItem () {
    const { itemToUpdate } = this
    if (itemToUpdate instanceof Backbone.Model) {
      return this._createAndUpdateItem(itemToUpdate)
    } else {
      // If the view was loaded from the URL, @itemToUpdate will be just
      // the URL persisted attributes instead of a model object
      return app.request('get:item:model', this.itemToUpdate._id)
      .then(this._createAndUpdateItem.bind(this))
    }
  },

  _createAndUpdateItem (item) {
    const action = entity => app.request('item:update:entity', item, entity)
    return this._createAndAction(action)
  },

  _createAndAction (action) {
    return this.beforeCreate()
    .then(this.model.create.bind(this.model))
    .then(action)
    .catch(error_.Complete('.meta', false))
    .catch(forms_.catchAlert.bind(null, this))
  },

  // Override in sub views
  async beforeCreate () {},

  signalDataError (e) {
    const uri = this.model.get('uri')
    const subject = I18n('data error')
    app.execute('show:feedback:menu', {
      subject: `[${uri}][${subject}] `,
      uris: [ uri ],
      event: e
    })
  },

  // Hiding navigation buttons when a label is required but no label is set yet
  // to invite the user to edit and save the label, or cancel.
  updateNavigationButtons () {
    if (this.missingData()) {
      if (!this.navigationButtonsDisabled) {
        this.ui.navigationButtons.hide()
        this.ui.missingDataMessage.show()
        this.navigationButtonsDisabled = true
      }
      this.$el.find('span.missingProperties').text(this.missingRequiredProperties.join(', '))
    } else {
      if (this.navigationButtonsDisabled) {
        this.ui.navigationButtons.fadeIn()
        this.ui.missingDataMessage.hide()
        this.navigationButtonsDisabled = false
      }
    }
  },

  missingData () {
    const labelsCount = _.values(this.model.get('labels')).length
    if (this.requiresLabel && (labelsCount === 0)) return true
    this.setMissingRequiredProperties()
    return this.missingRequiredProperties.length > 0
  },

  setMissingRequiredProperties () {
    this.missingRequiredProperties = []

    if (this.requiresLabel) {
      if (_.values(this.model.get('labels')).length <= 0) {
        this.missingRequiredProperties.push(i18n('title'))
      }
    }

    for (const property of this.requiredProperties) {
      if (this.model.get(`claims.${property}`)?.length <= 0) {
        const labelKey = propertiesPerType[this.model.type][property].customLabel || property
        this.missingRequiredProperties.push(i18n(labelKey))
      }
    }
  },

  moveToWikidataData () {
    let reason
    const uri = this.model.get('uri')

    // An entity being created on Inventaire won't have a URI at this point
    if ((uri == null) || isWikidataUri(uri)) return

    const type = this.model.get('type')
    if (type === 'edition') {
      reason = i18n("editions can't be moved to Wikidata for the moment")
      return { ok: false, reason }
    }

    const object = this.model.get('claims')
    for (const property in object) {
      // Known case where properties[property] is undefined: wdt:P31
      const values = object[property]
      if (properties[property]?.editorType === 'entity') {
        for (const value of values) {
          if (!isWikidataUri(value)) {
            const message = i18n("some values aren't Wikidata entities:")
            reason = `${message} ${i18n(unprefixify(property))}`
            return { ok: false, reason }
          }
        }
      }
    }

    return { ok: true }
  },

  moveToWikidata () {
    if (!app.user.hasWikidataOauthTokens()) {
      return app.execute('show:wikidata:edit:intro:modal', this.model)
    }

    startLoading.call(this, '#moveToWikidata')

    const uri = this.model.get('uri')
    return moveToWikidata(uri)
    // This should now redirect us to the new Wikidata edit page
    .then(() => app.execute('show:entity:edit', uri))
    .catch(error_.Complete('#moveToWikidata', false))
    .catch(forms_.catchAlert.bind(null, this))
  }
})

const isWikidataUri = uri => uri.split(':')[0] === 'wd'

const possessives = {
  work: "work's",
  edition: "edition's",
  serie: "series'",
  human: "author's",
  publisher: "publisher's",
  collection: "collection's"
}

const inventoryTypes = [ 'work', 'edition' ]
