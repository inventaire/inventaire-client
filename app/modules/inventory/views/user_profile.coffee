forms_ = require 'modules/general/lib/forms'
relationsActions = require 'modules/users/plugins/relations_actions'
{ buildPath } = require 'lib/location'

# TODO: add a 'close' button to allow to unfocus a user in group context
module.exports = Marionette.ItemView.extend
  className: 'userProfile'
  template: require './templates/user_profile'
  events:
    'click .edit': 'editProfile'
    # 'click a.showGroup': 'showGroup'
    # 'click #showPositionPicker': -> app.execute 'show:position:picker:main:user'
    'click .showUserOnMap': 'showUserOnMap'

  behaviors:
    PreventDefault: {}

  initialize: ->
    { @isMainUser } = @model
    @listenTo @model, 'change', @render.bind(@)
    @initPlugin()

  initPlugin: ->
    unless @isMainUser then relationsActions.call @

  serializeData: ->
    # Show private items in items counts if available
    nonPrivate = false
    _.extend @model.serializeData(nonPrivate),
      onUserProfile: true
      loggedIn: app.user.loggedIn
      positionUrl: @getPositionUrl()
      distance: @model.distanceFromMainUser
      # commonGroups: @commonGroupsData()
      # visitedGroups: @visitedGroupsData()
      # rss: @model.getRss()

  editProfile: (e)->
    if _.isOpenedOutside e then return
    app.execute 'show:settings:profile'

  # commonGroupsData: -> @_requestGroupData 'get:groups:common'
  # visitedGroupsData: -> @_requestGroupData 'get:groups:others:visited'

  # _requestGroupData: (request)->
  #   if @isMainUser then return
  #   groups = app.request(request, @model).map parseGroupData
  #   if groups.length > 0 then return groups else return null

  # showGroup: (e)->
  #   unless _.isOpenedOutside e
  #     groupId = e.currentTarget.attributes['data-id'].value
  #     app.execute 'show:inventory:group:byId', { groupId }

  getPositionUrl: ->
    unless @model.distanceFromMainUser? then return
    [ lat, lng ] = @model.get 'position'
    return buildPath '/network/users/nearby', { lat, lng }

  showUserOnMap: (e)->
    if _.isOpenedOutside(e) then return
    unless @model.distanceFromMainUser? then return
    [ lat, lng ] = @model.get 'position'
    app.execute 'show:users:nearby', { lat, lng }

# parseGroupData = (group)->
#   id: group.id
#   name: group.get('name')
#   pathname: group.get('pathname')
