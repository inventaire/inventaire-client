module.exports = Marionette.ItemView.extend
  template: require './templates/news_buttons'

  className: 'innerNewsButtons'

  initialize: ->
    @lazyRender = _.LazyRender @
    @once 'render', @initListeners.bind(@)

    # Re-render once app.relations is populated to display network counters
    app.request('wait:for', 'relations').then @lazyRender

  initListeners: ->
    @listenTo app.vent,
      'transactions:unread:change': @lazyRender
      'network:requests:update': @lazyRender

  serializeData: ->
    exchangesUpdates: app.request 'transactions:unread:count'
    notificationsUpdates: app.request 'notifications:unread:count'

  events:
    'click #exchangesIconButton': _.clickCommand 'show:transactions'
    'click #notificationsIconButton': _.clickCommand 'show:notifications'
