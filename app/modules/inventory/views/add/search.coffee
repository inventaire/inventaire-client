searchInputData = require 'modules/general/views/menu/search_input_data'

module.exports = Marionette.ItemView.extend
  tagName: 'section'
  template: require './templates/search'
  serializeData: ->
    search: searchInputData 'localSearch', true

  behaviors:
    PreventDefault: {}
    LocalSeachBar: {}
