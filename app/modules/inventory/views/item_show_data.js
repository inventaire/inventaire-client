// Motivation for having a view separated from ItemShowLayout:
// - no need to reload the image on re-render (like when details are saved)
import { capitalize } from 'lib/utils'
import itemShowDataTemplate from './templates/item_show_data.hbs'
import ItemTransactions from './item_transactions'
import getActionKey from 'lib/get_action_key'
import itemViewsCommons from '../lib/items_views_commons'
const ItemLayout = Marionette.LayoutView.extend(itemViewsCommons)

export default ItemLayout.extend({
  id: 'itemShowData',
  template: itemShowDataTemplate,
  regions: {
    transactionsRegion: '#transactions',
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
    'change:transaction': 'lazyRender',
    'change:listing': 'lazyRender',
    'change:notes': 'lazyRender',
    'change:details': 'lazyRender',
  },

  onRender () {
    if (app.user.loggedIn) this.showTransactions()
  },

  events: {
    'click button.transaction': 'updateTransaction',
    'click button.listing': 'updateListing',
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
    'click .requestItem' () { app.execute('show:item:request', this.model) },
  },

  serializeData () { return this.model.serializeData() },

  showNotesEditorFromKey (e) { this.showEditorFromKey('notes', e) },
  showDetailsEditorFromKey (e) { this.showEditorFromKey('details', e) },
  showEditorFromKey (editor, e) {
    const key = getActionKey(e)
    const capitalizedEditor = capitalize(editor)
    if (key === 'enter') this[`show${capitalizedEditor}Editor`]()
  },

  showDetailsEditor (e) { this.showEditor('details', e) },
  hideDetailsEditor (e) { this.hideEditor('details', e) },
  detailsEditorKeyAction (e) { this.editorKeyAction('details', e) },

  showNotesEditor (e) { this.showEditor('notes', e) },
  hideNotesEditor (e) { this.hideEditor('notes', e) },
  notesEditorKeyAction (e) { this.editorKeyAction('notes', e) },

  validateDetails () { this.validateEdit('details') },
  validateNotes () { this.validateEdit('notes') },

  showEditor (nameBase, e) {
    if (!this.model.mainUserIsOwner) return
    $(`#${nameBase}`).hide()
    $(`#${nameBase}Editor`).show().find('textarea').focus()
    this.$el.trigger('elastic:textarea:update')
    e?.stopPropagation()
  },

  hideEditor (nameBase, e) {
    $(`#${nameBase}`).show()
    $(`#${nameBase}Editor`).hide()
    e?.stopPropagation()
  },

  editorKeyAction (editor, e) {
    const key = getActionKey(e)
    const capitalizedEditor = capitalize(editor)
    if (key === 'esc') {
      const hideEditor = `hide${capitalizedEditor}Editor`
      this[hideEditor]()
      e.stopPropagation()
    } else if ((key === 'enter') && e.ctrlKey) {
      this.validateEdit(editor)
      e.stopPropagation()
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
    if (this.transactions == null) this.transactions = app.request('get:transactions:ongoing:byItemId', this.model.id)
    return Promise.all(_.invoke(this.transactions.models, 'beforeShow'))
    .then(this.ifViewIsIntact('_showTransactions'))
  },

  _showTransactions () {
    this.transactionsRegion.show(new ItemTransactions({ collection: this.transactions }))
  },
})
