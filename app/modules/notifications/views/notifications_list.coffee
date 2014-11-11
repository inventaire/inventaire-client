ListWithCounter = require 'views/menu/list_with_counter'

module.exports = class NotificationsList extends ListWithCounter
  childViewContainer: '.dropdown'
  childView: require './notification_li'
  emptyView: require './no_notification'
  serializeData: ->
    icon: 'globe'
