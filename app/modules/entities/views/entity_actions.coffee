module.exports = Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  behaviors:
    PreventDefault: {}

  initialize: ->
    @uri = @model.get 'uri'
    @mainUserInstances = app.request 'item:main:user:instances', @uri

  serializeData: ->
    transactions: @transactionsData()
    mainUserHasOne: @mainUserHasOne()
    mainUserInstances: @mainUserInstances
    instances:
      count: @mainUserInstances.length
      pathname: @mainUserInstancesPathname()

  transactionsData: ->
    transactions = Items.transactions()
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
    'click .hasAnInstance a': 'showMainUserInstances'

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

  mainUserHasOne: ->  @mainUserInstances.length > 0
  showMainUserInstances: -> app.execute 'show:items', @mainUserInstances
  mainUserInstancesPathname: ->
    uri = @uri
    username = app.user.get 'username'
    return "/inventory/#{username}/#{uri}"
