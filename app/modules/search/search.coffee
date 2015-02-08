Search = require './views/search'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    SearchRouter = Marionette.AppRouter.extend
      appRoutes:
        'search': 'search'

    app.addInitializer ->
      new SearchRouter
        controller: API

  initialize: ->
    app.commands.setHandlers
      'search:global': (queryString)->
        API.search(queryString)
        app.navigate "search?#{queryString}"

    app.reqres.setHandlers
      'search:entities': API.searchEntities

API =
  search: (queryString)->
    params =
      query: _.softDecodeURI(queryString)

    app.search = searchLayout = new Search(params)

    docTitle = "#{queryString} - " +  _.i18n('Search')
    app.layout.main.Show searchLayout, docTitle
