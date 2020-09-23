folders = require '../lib/folders'

module.exports = Marionette.CompositeView.extend
  template: require './templates/transactions_list'
  className: 'transactionList'
  childViewContainer: '.transactions'
  childView: require './transaction_preview'
  emptyView: require './no_transaction'
  initialize: ->
    @folder = @options.folder
    @filter = folders[@folder].filter
    @listenTo app.vent, 'transactions:folder:change', @render.bind(@)

  serializeData: ->
    attrs = {}
    attrs[@folder] = true
    return attrs
