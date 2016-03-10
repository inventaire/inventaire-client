searchInputData = require 'modules/general/views/menu/search_input_data'
scanner = require 'lib/scanner'
files_ = require 'lib/files'
imports = require '../../lib/imports'

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
    'change input[type=file]': 'getCsvFile'

  setAddModeScan: -> app.execute 'last:add:mode:set', 'scan'

  onShow: ->
    unless @loggedIn
      msg = 'you need to be connected to add a book to your inventory'
      app.execute 'show:call:to:connection', msg

  onDestroy: ->
    unless @loggedIn
      app.execute 'modal:close'

  getCsvFile: (e)->
    files_.parseFileEventAsText e, true, 'ISO-8859-1'
    # TODO: throw error on non-utf-8 encoding
    .then _.Log('csv files')
    .then imports.babelio
    .then _.Log('babelio parse')
