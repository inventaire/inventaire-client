behaviorsPlugin = require 'modules/general/plugins/behaviors'
{ BasicPlugin } = require 'lib/plugins'

events =
  'click .showGroup': 'showGroup'
  'click .showGroupBoard': 'showGroupBoard'
  'click .accept': 'acceptInvitation'
  'click .decline': 'declineInvitation'
  'click .joinRequest': 'joinRequest'
  'click .cancelRequest': 'cancelRequest'

handlers =
  showGroup: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:inventory:group', @model

  showGroupBoard: (e)->
    unless _.isOpenedOutside e
      app.execute 'show:group:board', @model

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
