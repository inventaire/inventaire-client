import log_ from 'lib/loggers'
import { i18n } from 'modules/user/lib/i18n'
import EntityDataOverview from 'modules/entities/views/entity_data_overview'
import ItemShelves from '../item_shelves'
import { listingsData, transactionsData, getSelectorData } from 'modules/inventory/lib/item_creation'
import { getShelvesByOwner } from 'modules/shelves/lib/shelves'
import UpdateSelector from 'modules/inventory/behaviors/update_selector'
import Shelves from 'modules/shelves/collections/shelves'
import forms_ from 'modules/general/lib/forms'
import error_ from 'lib/error'

const ItemsList = Marionette.CollectionView.extend({ childView: require('modules/inventory/views/item_row') })

export default Marionette.LayoutView.extend({
  template: require('./templates/item_creation.hbs'),
  className: 'addEntity',

  regions: {
    existingEntityItemsRegion: '#existingEntityItems',
    entityRegion: '#entity',
    shelvesSelector: '#shelvesSelector'
  },

  behaviors: {
    ElasticTextarea: {},
    UpdateSelector: {
      behaviorClass: UpdateSelector
    },
    AlertBox: {}
  },

  ui: {
    transaction: '#transaction',
    listing: '#listing',
    details: '#details',
    notes: '#notes',
    shelvesWrapper: '#shelvesWrapper'
  },

  initialize () {
    ({ entity: this.entity, existingEntityItems: this.existingEntityItems } = this.options)
    this.initItemData()
    this._lastAddMode = app.request('last:add:mode:get')

    this.waitForExistingInstances = app.request('item:main:user:entity:items', this.entity.get('uri'))
  },

  initItemData () {
    const { entity, transaction } = this.options

    this.itemData = {
      entity: entity.get('uri'),
      transaction: guessTransaction(transaction),
      listing: app.request('last:listing:get'),
      shelves: app.request('last:shelves:get') || []
    }

    // We need to specify a lang for work entities
    if (entity.type === 'work') { this.itemData.lang = guessLang(entity) }

    if (this.itemData.entity == null) { throw error_.new('missing uri', this.itemData) }
  },

  serializeData () {
    const title = this.entity.get('label')

    const attrs = {
      title,
      listings: listingsData(this.itemData.listing),
      transactions: transactionsData(this.itemData.transaction),
      header: i18n('add_item_text', { title })
    }

    return attrs
  },

  onShow () {
    this.showEntityData()
    this.showExistingInstances()
    this.showShelves()
  },

  events: {
    'click #transaction': 'updateTransaction',
    'click #listing': 'updateListing',
    'click #cancel': 'cancel',
    'click #validate': 'validateSimple',
    'click #validateAndAddNext': 'validateAndAddNext'
  },

  showEntityData () {
    return this.entityRegion.show(new EntityDataOverview({ model: this.entity }))
  },

  showExistingInstances () {
    return this.waitForExistingInstances
    .then(existingEntityItems => {
      if (existingEntityItems.length === 0) return
      const collection = new Backbone.Collection(existingEntityItems)
      this.$el.find('#existingEntityItemsWarning').show()
      return this.existingEntityItemsRegion.show(new ItemsList({ collection }))
    })
  },

  showShelves () {
    return getShelvesByOwner(app.user.id)
    .then(this.ifViewIsIntact('_showShelves'))
    .catch(log_.Error('showShelves err'))
  },

  _showShelves (shelves) {
    const selectedShelves = this.itemData.shelves
    // TODO: offer to create shelves from this form instead
    if (shelves.length > 0) {
      const collection = new Shelves(shelves, { selected: selectedShelves })
      this.shelvesSelector.show(new ItemShelves({
        collection,
        selectedShelves,
        mainUserIsOwner: true
      }))
      this.ui.shelvesWrapper.removeClass('hidden')
    }
  },

  // TODO: update the UI for update errors
  updateTransaction () {
    const transaction = getSelectorData(this, 'transaction')
    this.itemData.transaction = transaction
  },

  updateListing () {
    const listing = getSelectorData(this, 'listing')
    this.itemData.listing = listing
  },

  validateSimple () {
    this.createItem()
    .then(() => {
      const lastShelves = app.request('last:shelves:get')
      if ((lastShelves != null) && (lastShelves.length === 1)) {
        app.execute('show:shelf', lastShelves[0])
      } else {
        app.execute('show:inventory:main:user')
      }
    })
  },

  validateAndAddNext () {
    return this.createItem()
    .then(this.addNext.bind(this))
  },

  createItem () {
    // the value of 'transaction' and 'listing' were updated on selectors clicks
    this.itemData.details = this.ui.details.val()
    this.itemData.notes = this.ui.notes.val()
    this.itemData.shelves = this.getSelectedShelves()

    app.execute('last:shelves:set', this.itemData.shelves)

    return app.request('item:create', this.itemData)
    .catch(error_.Complete('.panel'))
    .catch(forms_.catchAlert.bind(null, this))
  },

  getSelectedShelves () {
    const selectedShelves = this.$el.find('.shelfSelector input')
      .filter((i, el) => el.checked)
      .map((i, el) => el.name.split('-')[1])
    return selectedShelves
  },

  addNext () {
    const { _lastAddMode } = this
    if (_lastAddMode === 'search') app.execute('show:add:layout:search')
    else if (_lastAddMode === 'scan:embedded') app.execute('show:scanner:embedded')
    else {
      // Known case: 'scan:zxing'
      log_.warn(this._lastAddMode, 'unknown or obsolete add mode')
      app.execute('show:add:layout')
    }
  },

  cancel () {
    if (Backbone.history.last.length > 0) {
      return window.history.back()
    } else {
      app.execute('show:home')
    }
  }
})

const guessTransaction = function (transaction) {
  transaction = transaction || app.request('last:transaction:get')
  if (transaction === 'null') { transaction = null }
  app.execute('last:transaction:set', transaction)
  return transaction
}

const guessLang = function (entity) {
  const { lang: userLang } = app.user
  const [ labels, originalLang ] = entity.gets('labels', 'originalLang')
  if (labels[userLang] != null) { return userLang }
  if (labels[originalLang] != null) { return originalLang }
  if (labels.en != null) { return 'en' }
  // If none of the above worked, return the first lang we find
  return Object.keys(labels)[0]
}
