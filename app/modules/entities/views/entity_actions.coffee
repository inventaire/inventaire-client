mainUserInstance = require '../plugins/main_user_has_one'

module.exports = Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  initialize: ->
    @uri = @model.get 'uri'

    # has to be initialized after Entities followedList which waitForData
    # app.request 'waitForData:after', @updateOnFollowStatusChange.bind(@)
    @initPlugins()

  initPlugins: ->
    mainUserInstance.call @

  # updateOnFollowStatusChange: ->
  #   eventName = "change:#{@uri}"
  #   followedList = app.request 'entities:followed:list'
  #   @listenTo followedList, eventName, @render

  serializeData: ->
    # @following = app.request 'entity:followed:state', @uri
    return _.log attrs =
      # following: @following
      transactions: @transactionsData()
      mainUserHasOne: @mainUserHasOne()

  transactionsData: ->
    transactions = _.clone Items.transactions
    transactions.inventorying.icon = 'plus'
    transactions.inventorying.label = 'just_inventorize_it'
    return transactions

  onRender: ->
    app.execute 'foundation:reload'

  # ui:
  #   stopFollowing: '#stopFollowing'

  events:
    'click #addToInventory, #inventorying': 'inventorying'
    'click #giving': 'giving'
    'click #lending': 'lending'
    'click #selling': 'selling'
    # 'click #followActivity': 'followActivity'
    # 'click #stopFollowing': 'stopFollowing'

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

  # followActivity: ->
  #   app.execute 'entity:follow', @uri

  # stopFollowing: ->
  #   app.execute 'entity:unfollow', @uri
