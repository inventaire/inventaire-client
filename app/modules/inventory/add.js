AddLayout = require './views/add/add_layout'
initAddHelpers = require './lib/add_helpers'
EmbeddedScanner = require './views/add/embedded_scanner'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'add(/search)(/)': 'showSearch'
        'add/scan(/)': 'showScan'
        'add/scan/embedded(/)': 'showEmbeddedScanner'
        'add/import(/)': 'showImport'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    initAddHelpers()
    initializeHandlers()

API =
  showSearch: -> showAddLayout 'search'
  showScan: -> showAddLayout 'scan'
  showImport: -> showAddLayout 'import'
  showEmbeddedScanner: ->
    if app.request 'require:loggedIn', 'add/scan/embedded'
      if window.hasVideoInput
        # navigate before triggering the view itself has
        # special behaviors on route change
        app.navigate 'add/scan/embedded'
        # showing in main so that requesting another layout destroy this view
        app.layout.main.show new EmbeddedScanner
      else
        API.showScan()

showAddLayout = (tab = 'search', options = {})->
  if app.request 'require:loggedIn', "add/#{tab}"
    options.tab = tab
    app.layout.main.show new AddLayout options

initializeHandlers = ->
  app.commands.setHandlers
    'show:add:layout': showAddLayout
    # equivalent to the previous one as long as search is the default tab
    # but more explicit
    'show:add:layout:search': API.showSearch

    'show:add:layout:import:isbns': (isbnsBatch)->
      showAddLayout 'import', { isbnsBatch }

    'show:scan': API.showScan

    'show:scanner:embedded': API.showEmbeddedScanner
