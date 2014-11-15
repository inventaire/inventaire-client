ListWithCounter = require 'views/menu/list_with_counter'

module.exports = class RequestsList extends ListWithCounter
  childView: require 'views/users/user_li'
  emptyView: require './no_request'
  serializeData: ->  icon: 'user'
