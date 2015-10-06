module.exports = Marionette.ItemView.extend
  template: require './templates/group_board_header'
  className: 'group-board-header'
  initialize: ->
    @lazyRender = _.LazyRender @
    @listenTo @model, 'change', @lazyRender

    # update the book counter when all items arrived
    app.request('waitForFriendsItems').then @lazyRender

  serializeData:->
    attrs = @model.serializeData()
    attrs.invitor = @invitorData()
    return attrs

  invitorData: ->
    username = @model.findMainUserInvitor()?.get('username')
    return {username: username}
