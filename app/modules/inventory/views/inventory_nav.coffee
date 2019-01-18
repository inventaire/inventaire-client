module.exports = Marionette.ItemView.extend
  template: require './templates/inventory_nav'
  initialize: ->
    @selectedUser = @options.user

  serializeData: ->
    user: app.user.toJSON()
    selectedTab: @getSelectedTab()

  getSelectedTab: ->
    if @selectedUser is app.user then return 'user'
    else return 'network'
