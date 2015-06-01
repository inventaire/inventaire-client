folders = require 'modules/transactions/lib/folders'

module.exports = Marionette.CompositeView.extend
  className: 'itemTransactions panel'
  template: require './templates/item_transactions'
  childViewContainer: '.transactions'
  childView: require 'modules/transactions/views/transaction_preview'
  childViewOptions:
    onItem: true
  filter: folders.ongoing.filter
