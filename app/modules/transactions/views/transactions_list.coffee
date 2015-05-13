Filter = require '../lib/transactions_filter'

module.exports = Marionette.CompositeView.extend
  template: require './templates/transactions_list'
  className: 'transactionList'
  childViewContainer: '.transactions'
  childView: require './transaction_preview'
  emptyView: require './no_transaction'
  initialize: ->
    @state = @options.state
    @pickFilter()

  serializeData: ->
    attrs = {}
    attrs[@state] = true
    return attrs

  pickFilter: ->
    switch @state
      when 'received' then @filter = Filter 'requested', 'owner'
      when 'sent' then @filter = Filter 'requested', 'requester'
      else _.error "unknown state: #{@state}"
