NetworkLayout = require './views/network_layout'
initGroupHelpers = require './lib/group_helpers'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'network(/)': 'showNetworkLayout'
        'network/friends(/)': 'showNetworkLayoutFriends'
        'network/groups(/)': 'showNetworkLayoutGroups'
        # group routes are in the inventory router

    app.addInitializer ->
      new Router
        controller: API

  initialize: ->
    app.commands.setHandlers
      'show:network': API.showNetworkLayout
      'show:network:friends': API.showNetworkLayoutFriends
      'show:network:groups': API.showNetworkLayoutGroups

    app.request('waitForUserData')
    .then initGroupHelpers

API =
  showNetworkLayoutFriends: -> @showNetworkLayout 'friends'
  showNetworkLayoutGroups: -> @showNetworkLayout 'groups'
  showNetworkLayout: (tab="friends")->
    app.layout.main.Show new NetworkLayout
      title: _.i18n tab
      tab: tab
