{ data: transactionsData } = require 'modules/inventory/lib/transactions_data'

module.exports = Marionette.CompositeView.extend
  template: require './templates/items_preview_list'
  className: ->
    className = 'itemsPreviewList'
    if @options.compact then className += ' compact'
    return className

  childViewContainer: '.items-preview'
  childView: require './item_preview'
  childViewOptions: ->
    displayItemsCovers: @options.displayItemsCovers
    compact: @options.compact

  initialize: ->
    { @transaction } = @options

  serializeData: ->
    transaction: @transaction
    icon: transactionsData[@transaction].icon
