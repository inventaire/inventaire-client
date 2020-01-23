forms_ = require 'modules/general/lib/forms'
relationsActions = require 'modules/users/plugins/relations_actions'
{ buildPath } = require 'lib/location'

# TODO: add a 'close' button to allow to unfocus a user in group context
module.exports = Marionette.ItemView.extend
  className: 'userProfile'
  template: require './templates/user_profile'
  events:
    'click .edit': 'editProfile'
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

  editProfile: (e)->
    if _.isOpenedOutside e then return
    app.execute 'show:settings:profile'

  getPositionUrl: ->
    unless @model.distanceFromMainUser? then return
    [ lat, lng ] = @model.get 'position'
    return buildPath '/network/users/nearby', { lat, lng }

  showUserOnMap: (e)->
    if _.isOpenedOutside(e) then return
    unless @model.distanceFromMainUser? then return
    [ lat, lng ] = @model.get 'position'
    app.execute 'show:users:nearby', { lat, lng }
