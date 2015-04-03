ListWithCounter = require 'modules/general/views/menu/list_with_counter'

module.exports = RequestsList = ListWithCounter.extend
  childView: require './request_li'
  emptyView: require './no_request'
  className: 'requests has-dropdown not-click'
  serializeData: ->
    icon: 'user-plus'
    label: _.i18n 'friends requests'