mainUserInstance = require '../plugins/main_user_has_one'

module.exports = Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  initialize: ->
    @uri = @model.get 'uri'

    @initPlugins()

  initPlugins: ->
    mainUserInstance.call @

  serializeData: ->
    return _.log attrs =
      transactions: @transactionsData()
      mainUserHasOne: @mainUserHasOne()

  transactionsData: ->
    transactions = _.clone Items.transactions
    transactions.inventorying.icon = 'plus'
    transactions.inventorying.label = 'just_inventorize_it'
    return transactions

  onRender: ->
    app.execute 'foundation:reload'

  events:
    'click #addToInventory, #inventorying': 'inventorying'
    'click #giving': 'giving'
    'click #lending': 'lending'
    'click #selling': 'selling'

  giving: -> @showItemCreation 'giving'
  lending: -> @showItemCreation 'lending'
  selling: -> @showItemCreation 'selling'
  inventorying: -> @showItemCreation 'inventorying'

  showItemCreation: (transaction)->
    if @model.delegateItemCreation
      @model.trigger 'delegate:item:creation', transaction
      _.log 'delegating item creation'
    else
      app.execute 'show:item:creation:form',
        entity: @model
        transaction: transaction
