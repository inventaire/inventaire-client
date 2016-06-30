groupPlugin = require '../plugins/group'

module.exports = Marionette.ItemView.extend
  template: require './templates/group_board_header'
  className: 'group-board-header'
  initialize: ->
    @initPlugin()
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender

    # update the book counter when all items arrived
    app.request('wait:for', 'friends:items').then @lazyRender

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
