import log_ from 'lib/loggers'
import itemShowDataTemplate from './templates/item_show_data.hbs'

// Motivation for having a view separated from ItemShow:
// - no need to reload the image on re-render (like when details are saved)

import ItemTransactions from './item_transactions'

import getActionKey from 'lib/get_action_key'
import ItemShelves from './item_shelves'
import Shelves from 'modules/shelves/collections/shelves'
import { getShelvesByOwner, getByIds as getShelvesByIds } from 'modules/shelves/lib/shelves'
import itemViewsCommons from '../lib/items_views_commons'
const ItemLayout = Marionette.LayoutView.extend(itemViewsCommons)

export default ItemLayout.extend({
  id: 'itemShowData',
  template: itemShowDataTemplate,
  regions: {
    transactionsRegion: '#transactions',
    shelvesSelector: '#shelvesSelector'
  },

  ui: {
    shelvesPanel: '.shelvesPanel',
    toggleShelvesExpand: '.toggleShelvesExpand'
  },

  behaviors: {
    ElasticTextarea: {},
    AlertBox: {}
  },

  initialize () {
    // The alertbox is appended to the target's parent, which might have
    // historical reasons but seems a bit dumb now
    this.alertBoxTarget = '.leftBox .panel'
  },

  modelEvents: {
    'change:notes': 'lazyRender',
    'change:details': 'lazyRender',
    'change:shelves': 'updateShelves',
    'add:shelves': 'updateShelves'
  },

  onRender () {
    if (app.user.loggedIn) { this.showTransactions() }
  },

  events: {
    'click a.transaction': 'updateTransaction',
    'click a.listing': 'updateListing',
    'click a.remove': 'itemDestroy',
    'click a.itemShow': 'itemShow',
    'click a.user': 'showUser',
    'click a.showUser': 'showUser',
    'click a.mainUserRequested': 'showTransaction',

    'click a#editDetails': 'showDetailsEditor',
    'click .detailsPanel': 'showDetailsEditor',

    // show editor when focused and 'enter' is pressed
    'keydown .noteBox': 'showNotesEditorFromKey',
    'keydown .detailsPanel': 'showDetailsEditorFromKey',

    'keydown #detailsEditor': 'detailsEditorKeyAction',
    'click a#cancelDetailsEdition': 'hideDetailsEditor',
    'click a#validateDetails': 'validateDetails',
    'click a#editNotes': 'showNotesEditor',
    'click .noteBox': 'showNotesEditor',
    'click a#cancelNotesEdition': 'hideNotesEditor',
    'keydown #notesEditor': 'notesEditorKeyAction',
    'click a#validateNotes': 'validateNotes',
    'click a.requestItem' () { app.execute('show:item:request', this.model) },
    'click .selectShelf': 'selectShelf',
    'click .toggleShelvesExpand': 'toggleShelvesExpand'
  },

  serializeData () { return this.model.serializeData() },

  onShow () {
    this.showShelves()
  },

  itemDestroyBack () {
    if (this.model.isDestroyed) {
      app.execute('modal:close')
    } else { app.execute('show:item', this.model) }
  },

  showNotesEditorFromKey (e) { this.showEditorFromKey('notes', e) },
  showDetailsEditorFromKey (e) { this.showEditorFromKey('details', e) },
  showEditorFromKey (editor, e) {
    const key = getActionKey(e)
    const capitalizedEditor = _.capitalise(editor)
    if (key === 'enter') { return this[`show${capitalizedEditor}Editor`]() }
  },

  showDetailsEditor (e) { this.showEditor('details', e) },
  hideDetailsEditor (e) { return this.hideEditor('details', e) },
  detailsEditorKeyAction (e) { return this.editorKeyAction('details', e) },

  showNotesEditor (e) { this.showEditor('notes', e) },
  hideNotesEditor (e) { return this.hideEditor('notes', e) },
  notesEditorKeyAction (e) { return this.editorKeyAction('notes', e) },

  validateDetails () { return this.validateEdit('details') },
  validateNotes () { return this.validateEdit('notes') },

  showEditor (nameBase, e) {
    if (!this.model.mainUserIsOwner) return
    $(`#${nameBase}`).hide()
    $(`#${nameBase}Editor`).show().find('textarea').focus()
    return e?.stopPropagation()
  },

  hideEditor (nameBase, e) {
    $(`#${nameBase}`).show()
    $(`#${nameBase}Editor`).hide()
    return e?.stopPropagation()
  },

  editorKeyAction (editor, e) {
    const key = getActionKey(e)
    const capitalizedEditor = _.capitalise(editor)
    if (key === 'esc') {
      const hideEditor = `hide${capitalizedEditor}Editor`
      this[hideEditor]()
      return e.stopPropagation()
    } else if ((key === 'enter') && e.ctrlKey) {
      this.validateEdit(editor)
      return e.stopPropagation()
    }
  },

  validateEdit (nameBase) {
    this.hideEditor(nameBase)
    const edited = $(`#${nameBase}Editor textarea`).val()
    if (edited !== this.model.get(nameBase)) {
      return app.request('items:update', {
        items: [ this.model ],
        attribute: nameBase,
        value: edited,
        selector: `#${nameBase}Editor`
      })
    }
  },

  showTransactions () {
    if (this.transactions == null) { this.transactions = app.request('get:transactions:ongoing:byItemId', this.model.id) }
    return Promise.all(_.invoke(this.transactions.models, 'beforeShow'))
    .then(this.ifViewIsIntact('_showTransactions'))
  },

  _showTransactions () {
    return this.transactionsRegion.show(new ItemTransactions({ collection: this.transactions }))
  },

  showShelves () {
    return this.getShelves()
    .then(shelves => {
      this.shelves = new Shelves(shelves, { selected: this.model.get('shelves') })
    })
    .then(this.ifViewIsIntact('_showShelves'))
    .catch(log_.Error('showShelves err'))
  },

  getShelves () {
    if (this.model.mainUserIsOwner) {
      return getShelvesByOwner(app.user.id)
    } else {
      const itemShelves = this.model.get('shelves')
      if (itemShelves?.length <= 0) { return Promise.resolve([]) }
      return getShelvesByIds(itemShelves)
      .then(_.values)
    }
  },

  _showShelves () {
    if (this.shelves.length === 0) {
      this.ui.shelvesPanel.hide()
      return
    }

    return this.shelvesSelector.show(new ItemShelves({
      collection: this.shelves,
      item: this.model,
      mainUserIsOwner: this.model.mainUserIsOwner
    })
    )
  },

  selectShelf (e) {
    const shelfId = e.currentTarget.href.split('/').slice(-1)[0]
    app.execute('show:shelf', shelfId)
  },

  updateShelves () {
    if (this.model.mainUserIsOwner) {
      if (this.shelves.length > this.model.get('shelves').length) {
        this.ui.toggleShelvesExpand.show()
      } else {
        this.ui.toggleShelvesExpand.hide()
      }
    }
  },

  afterDestroy () {
    app.execute('show:inventory:main:user')
  },

  toggleShelvesExpand () { this.$el.find('.shelvesPanel').toggleClass('expanded') }
})
