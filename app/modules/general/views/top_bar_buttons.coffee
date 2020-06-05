screen_ = require 'lib/screen'

module.exports = Marionette.ItemView.extend
  template: require './templates/top_bar_buttons'

  className: 'innerTopBarButtons'

  initialize: ->

    @listenTo app.vent,
      'screen:mode:change': @lazyRender.bind(@)
      'transactions:unread:change': @lazyRender.bind(@)
      'network:requests:update': @lazyRender.bind(@)

    # Re-render once relations and groups are populated to display network counters
    Promise.all [
      app.request 'wait:for', 'relations'
      app.request 'wait:for', 'groups'
    ]
    .then @lazyRender.bind(@)

  serializeData: ->
    smallScreen: screen_.isSmall()
    exchangesUpdates: app.request 'transactions:unread:count'
    notificationsUpdates: @getNotificationsCount()
    username: app.user.get 'username'
    userPicture: app.user.get 'picture'
    userPathname: app.user.get 'pathname'

  events:
    'click #exchangesIconButton': _.clickCommand 'show:transactions'
    'click #notificationsIconButton': _.clickCommand 'show:notifications'

    'click .showMainUser': _.clickCommand 'show:inventory:main:user'
    'click .showSettings': _.clickCommand 'show:settings'
    'click .showInfo': _.clickCommand 'show:welcome'
    'click .showFeedbackMenu': _.clickCommand 'show:feedback:menu'
    'click .logout': -> app.execute 'logout'

  getNotificationsCount: ->
    unreadNotifications = app.request 'notifications:unread:count'
    networkRequestsCount = app.request 'get:network:invitations:count'
    return unreadNotifications + networkRequestsCount
