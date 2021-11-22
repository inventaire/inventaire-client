import ShelfModel from '../models/shelf'
import getActionKey from 'lib/get_action_key'
import forms_ from 'modules/general/lib/forms'
import UpdateSelector from 'modules/inventory/behaviors/update_selector'
import { listingsData } from 'modules/inventory/lib/item_creation'
import { createShelf as createShelfModel } from 'modules/shelves/lib/shelves'
import { startLoading } from 'modules/general/plugins/behaviors'
import shelfEditorTemplate from './templates/shelf_editor.hbs'

export default Marionette.View.extend({
  template: shelfEditorTemplate,

  behaviors: {
    AlertBox: {},
    BackupForm: {},
    ElasticTextarea: {},
    Loading: {},
    UpdateSelector: {
      behaviorClass: UpdateSelector
    }
  },

  initialize () {
    app.execute('last:listing:set', 'private')
  },

  events: {
    'keydown .shelfEditor': 'shelfEditorKeyAction',
    'click .validate': 'createShelf'
  },

  serializeData () {
    return {
      isNewShelf: true,
      listings: listingsData()
    }
  },

  onShow () { app.execute('modal:open') },

  shelfEditorKeyAction (e) {
    const key = getActionKey(e)
    if (key === 'esc') {
      return this.closeModal()
    } else if ((key === 'enter') && e.ctrlKey) {
      return this.createShelf()
    }
  },

  closeModal () { app.execute('modal:close') },

  createShelf () {
    const name = $('#shelfNameEditor').val()
    let description = $('#shelfDescEditor ').val()
    if (description === '') description = null
    startLoading.call(this, '.validate .loading')
    const selectedListing = app.request('last:listing:get') || 'private'
    return createShelfModel({ name, description, listing: selectedListing })
    .then(afterCreate)
    .catch(forms_.catchAlert.bind(null, this))
  }
})

const afterCreate = function (newShelf) {
  const newShelfModel = new ShelfModel(newShelf)
  app.user.trigger('shelves:change', 'createShelf')
  app.execute('show:shelf', newShelfModel)
  app.execute('modal:close')
}
