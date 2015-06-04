searchInputData = require 'modules/general/views/menu/search_input_data'
scanner = require 'lib/scanner'

module.exports = Marionette.LayoutView.extend
  template: require './templates/add_layout'
  id: 'addLayout'
  serializeData: ->
    attrs =
      search: searchInputData()

    attrs.search.button.classes += ' postfix'

    if _.isMobile then attrs.scanner = scanner.url
    return attrs

  behaviors:
    PreventDefault: {}
    ElasticTextarea: {}
