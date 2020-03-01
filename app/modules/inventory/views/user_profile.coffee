forms_ = require 'modules/general/lib/forms'
relationsActions = require 'modules/users/plugins/relations_actions'
{ buildPath } = require 'lib/location'

# TODO: add a 'close' button to allow to unfocus a user in group context
module.exports = Marionette.ItemView.extend
  className: 'userProfile'
  template: require './templates/user_profile'
  events:
    'click .editProfile': _.clickCommand 'show:settings:profile'
    'click .addItems': _.clickCommand 'show:add:layout'
    'click .showUserOnMap': 'showUserOnMap'
    'click #showShelvesList': 'showShelvesList'

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

  getPositionUrl: ->
    unless @model.distanceFromMainUser? then return
    [ lat, lng ] = @model.get 'position'
    return buildPath '/network/users/nearby', { lat, lng }

  showUserOnMap: (e)->
    if _.isOpenedOutside(e) then return
    unless @model.distanceFromMainUser? then return
    app.execute 'show:models:on:map', [ @model, app.user ]

  showShelvesList: (e)->
    app.navigateFromModel @model, { preventScrollTop: true }
    app.execute 'show:shelves:list', @model
