ListWithCounter = require 'modules/general/views/menu/list_with_counter'

module.exports = class NotificationsList extends ListWithCounter
  childView: require './notification_li'
  emptyView: require './no_notification'
  serializeData: ->  icon: 'globe'
  className: 'notifications has-dropdown not-click'
  events:
    'mouseenter': 'markNotificationsAsRead'

  markNotificationsAsRead: -> @collection.markAsRead()
  count: -> @collection.unread().length

  initialize: ->
    app.commands.setHandlers
      'notifications:close': -> @$el.removeClass('hover')