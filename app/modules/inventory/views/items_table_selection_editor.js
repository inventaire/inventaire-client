import { transactionsData } from '../lib/transactions_data'
import { getShelvesByOwner } from 'modules/shelves/lib/shelves'
import ItemShelves from './item_shelves'
import Shelves from 'modules/shelves/collections/shelves'
import itemsTableSelectionEditorTemplate from './templates/items_table_selection_editor.hbs'
import '../scss/items_table_selection_editor.scss'

export default Marionette.LayoutView.extend({
  className: 'items-table-selection-editor',
  template: itemsTableSelectionEditorTemplate,
  events: {
    'click .transaction-option': 'setTransaction',
    'click .listing-option': 'setListing',
    'click .delete': 'deleteItems',
    'click .done' () { app.execute('modal:close') }
  },

  regions: {
    shelvesSelector: '.shelvesSelector'
  },

  initialize () {
    ({ getSelectedModelsAndIds: this.getSelectedModelsAndIds, selectedIds: this.selectedIds } = this.options)
  },

  serializeData () {
    return {
      selectedIdsCount: this.selectedIds.length,
      transactions: transactionsData,
      listings: app.user.listings()
    }
  },

  onShow () {
    app.execute('modal:open')
    this.showShelves()
  },

  setTransaction (e) { return this.updateItems(e, 'transaction') },

  setListing (e) { return this.updateItems(e, 'listing') },

  updateItems (e, attribute) {
    const value = e.currentTarget.id
    const { selectedModelsAndIds } = this.getSelectedModelsAndIds()
    app.request('items:update', { items: selectedModelsAndIds, attribute, value })
    app.execute('modal:close')
  },

  deleteItems () {
    if (this.selectedIds.length === 0) return

    const { selectedModelsAndIds } = this.getSelectedModelsAndIds()

    return app.request('items:delete', {
      items: selectedModelsAndIds,
      next: this.options.afterItemsDelete
    })
  },

  afterItemsDelete () {
    app.execute('modal:close')
    return this.options.afterItemsDelete()
  },

  showShelves () {
    return getShelvesByOwner(app.user.id)
    .then(this.ifViewIsIntact('_showShelves'))
  },

  _showShelves (shelves) {
    const shelvesCollection = new Shelves(shelves)
    this.shelvesSelector.show(new ItemShelves({
      collection: shelvesCollection,
      itemsIds: this.selectedIds
    }))
  }
})
