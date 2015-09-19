searchInputData = require 'modules/general/views/menu/search_input_data'
scanner = require 'lib/scanner'

module.exports = Marionette.LayoutView.extend
  template: require './templates/add_layout'
  id: 'addLayout'
  initialize: ->
    @loggedIn = app.user.loggedIn
  serializeData: ->
    attrs =
      search: searchInputData 'localSearch', true
      loggedIn: @loggedIn

    if _.isMobile then attrs.scanner = scanner.url
    return attrs

  behaviors:
    PreventDefault: {}
    ElasticTextarea: {}
    LocalSeachBar: {}

  events:
    'click #scanner': 'setAddModeScan'

  setAddModeScan: -> app.execute 'last:add:mode:set', 'scan'

  onShow: ->
    unless @loggedIn
      msg = 'you need to be connected to add a book to your inventory'
      app.execute 'show:call:to:connection', msg

  onDestroy: ->
    unless @loggedIn
      app.execute 'modal:close'