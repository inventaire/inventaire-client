ListWithCounter = require 'modules/general/views/menu/list_with_counter'

module.exports = class NotificationsList extends ListWithCounter
  childView: require './notification_li'
  emptyView: require './no_notification'
  serializeData: ->  icon: 'globe'
