ListWithCounter = require 'modules/general/views/menu/list_with_counter'

module.exports = class RequestsList extends ListWithCounter
  childView: require './request_li'
  emptyView: require './no_request'
  className: 'requests has-dropdown not-click'
  serializeData: ->
    icon: 'user'
    label: _.i18n 'Friends requests'