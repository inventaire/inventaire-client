module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  initialize: ->
    @uri = @model.get('uri')

    # has to be initialized after Entities followedList which waitForData
    app.request 'waitForData:after', @updateOnFollowStatusChange.bind(@)

  updateOnFollowStatusChange: ->
    eventName = "change:#{@uri}"
    followedList = app.request('entities:followed:list')
    @listenTo followedList, eventName, @render

  serializeData: ->
    @following = app.request 'entity:followed:state', @uri
    return attrs =
      following: @following
      transactions: @transactionsData()

  transactionsData: ->
    transactions = _.clone Items.transactions
    transactions.inventorying.icon = 'plus'
    transactions.inventorying.label = 'inventorize_it'
    return transactions

  onRender: ->
    app.execute 'foundation:reload'

  ui:
    stopFollowing: '#stopFollowing'

  events:
    'click #addToInventory, #inventorying': 'inventorying'
    'click #giving': 'giving'
    'click #lending': 'lending'
    'click #selling': 'selling'
    'click #followActivity': 'followActivity'
    'click #stopFollowing': 'stopFollowing'

  giving: -> @showItemCreation 'giving'
  lending: -> @showItemCreation 'lending'
  selling: -> @showItemCreation 'selling'
  inventorying: -> @showItemCreation 'inventorying'

  showItemCreation: (transaction)->
    params =
      entity: @model
      transaction: transaction
    _.log params, 'item:creation:params'
    app.execute 'show:item:creation:form', params

  followActivity: ->
    app.execute 'entity:follow', @uri

  stopFollowing: ->
    app.execute 'entity:unfollow', @uri
