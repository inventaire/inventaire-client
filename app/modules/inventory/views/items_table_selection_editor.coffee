{ data: transactionsData } = require '../lib/transactions_data'

module.exports = Marionette.ItemView.extend
  className: 'items-table-selection-editor'
  template: require './templates/items_table_selection_editor'
  events:
    'click .transaction-option': 'setTransaction'
    'click .listing-option': 'setListing'
    'click .delete': 'deleteItems'

  initialize: ->
    { @getSelectedModelsAndIds, @selectedIds } = @options

  serializeData: ->
    selectedIdsCount: @selectedIds.length
    transactions: transactionsData
    listings: app.user.listings()

  onShow: ->
    app.execute 'modal:open'

  setTransaction: (e)-> @updateItems e, 'transaction'

  setListing: (e)-> @updateItems e, 'listing'

  updateItems: (e, attribute)->
    value = e.currentTarget.id
    { selectedModelsAndIds } = @getSelectedModelsAndIds()
    app.request 'items:update', { items: selectedModelsAndIds, attribute, value }
    app.execute 'modal:close'

  deleteItems: ->
    if @selectedIds.length is 0 then return

    { selectedModelsAndIds, selectedModels, selectedIds } = @getSelectedModelsAndIds()

    app.request 'items:delete',
      items: selectedModelsAndIds
      next: @options.afterItemsDelete

  afterItemsDelete: ->
    app.execute 'modal:close'
    @options.afterItemsDelete()
