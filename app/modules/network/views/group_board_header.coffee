groupPlugin = require '../plugins/group'

module.exports = Marionette.ItemView.extend
  template: require './templates/group_board_header'
  className: 'group-board-header'
  initialize: ->
    @initPlugin()
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender

    # TODO: recover users items counters from user.snapshot.items:count data

  initPlugin: ->
    groupPlugin.call @

  behaviors:
    PreventDefault: {}

  serializeData:->
    attrs = @model.serializeData()
    attrs.invitor = @invitorData()
    return attrs

  invitorData: ->
    username = @model.findMainUserInvitor()?.get('username')
    return {username: username}
