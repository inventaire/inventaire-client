module.exports = Backbone.Marionette.ItemView.extend
  template: require './templates/entity_actions'
  className: 'entityActions'
  initialize: ->
    @updateOnFollowStatusChange()

  updateOnFollowStatusChange: ->
    @uri = @model.get('uri')
    eventName = "change:#{@uri}"
    followedList = app.request('entities:followed:list')
    @listenTo followedList, eventName, @render

  serializeData: ->
    following = app.request('entity:followed:state', @uri)
    return attrs =
      following: following

  onRender: -> app.execute 'foundation:reload'

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
    @$el.once 'mouseleave #stopFollowing', @initiateButtonToggler.bind(@)

  stopFollowing: ->
    app.execute 'entity:unfollow', @uri

  initiateButtonToggler: ->
    @ui.stopFollowing
    .mouseenter @toggleStopFollowingButtons.bind(@)
    .mouseleave @toggleStopFollowingButtons.bind(@)

  toggleStopFollowingButtons: ->
    @ui.stopFollowing
    .toggleClass('warn')
    .find('span').toggle()
