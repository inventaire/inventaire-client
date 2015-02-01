ListWithCounter = require 'modules/general/views/menu/list_with_counter'

module.exports = class NotificationsList extends ListWithCounter
  childView: require './notification_li'
  emptyView: require './no_notification'
  serializeData: ->
    icon: 'globe'
    label: _.i18n 'notifications'

  className: 'notifications has-dropdown not-click'
  events:
    'click .listWithCounter': 'markNotificationsAsRead'

  markNotificationsAsRead: -> @collection.markAsRead()
  count: -> @collection.unread().length

  initialize: ->
    @initUpdaters()
    app.commands.setHandlers
      'notifications:menu:close': -> @$el.removeClass('hover')