screen_ = require 'lib/screen'

module.exports = Marionette.ItemView.extend
  template: require './templates/top_bar_buttons'

  className: 'innerTopBarButtons'

  initialize: ->
    @lazyRender = _.LazyRender @

    @listenTo app.vent,
      'screen:mode:change': @lazyRender
      'transactions:unread:change': @lazyRender
      'network:requests:update': @lazyRender

    # Re-render once app.relations is populated to display network counters
    app.request('wait:for', 'relations').then @lazyRender

  serializeData: ->
    smallScreen: screen_.isSmall()
    exchangesUpdates: app.request 'transactions:unread:count'
    notificationsUpdates: app.request 'notifications:unread:count'
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
