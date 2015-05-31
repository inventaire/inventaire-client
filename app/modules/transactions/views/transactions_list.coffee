module.exports = Marionette.CompositeView.extend
  template: require './templates/transactions_list'
  className: 'transactionList'
  childViewContainer: '.transactions'
  childView: require './transaction_preview'
  emptyView: require './no_transaction'
  initialize: ->
    @folder = @options.folder
    @filter = @pickFilter()
    @listenTo app.vent, 'transactions:folder:change', @render.bind()

  serializeData: ->
    attrs = {}
    attrs[@folder] = true
    return attrs

  pickFilter: ->
    switch @folder
      when 'active' then active
      when 'archived' then archived
      else _.error "unknown folder: #{@folder}"

active = (transac, index, collection)-> not transac.archived
archived = (transac, index, collection)-> transac.archived
