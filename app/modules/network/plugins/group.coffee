behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ BasicPlugin } = require 'lib/plugins'

events =
  'click .showGroup': 'showGroup'
  'click .showGroupBoard': 'showGroupBoard'
  'click .showGroupSettings': 'showGroupSettings'
  'click .showMembersMenu': 'showMembersMenu'
  'click .accept': 'acceptInvitation'
  'click .decline': 'declineInvitation'
  'click .joinRequest': 'joinRequest'
  'click .cancelRequest': 'cancelRequest'

handlers =
  showGroup: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:inventory:group', @model

  showGroupBoard: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:group:board', @model

  showGroupSettings: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:group:board', @model, { openedSections: [ 'groupSettings' ] }

  showMembersMenu: (e)->
    if _.isOpenedOutside e then return
    else app.execute 'show:group:board', @model, { openedSections: [ 'groupInvite', 'groupEmailInvite' ] }

  acceptInvitation: -> @model.acceptInvitation()
  declineInvitation: -> @model.declineInvitation()
  joinRequest: ->
    if app.request 'require:loggedIn', @model.get('pathname')
      @model.requestToJoin()
      .catch behaviorsPlugin.Fail.call(@, 'joinRequest')

  cancelRequest: ->
    @model.cancelRequest()
    .catch behaviorsPlugin.Fail.call(@, 'cancelRequest')

module.exports = BasicPlugin events, handlers
