ListWithCounter = require 'views/menu/list_with_counter'

module.exports = class RequestsList extends ListWithCounter
  childViewContainer: '.dropdown'
  childView: require './request_li'
  emptyView: require './no_request'
  serializeData: ->
    icon: 'user'
