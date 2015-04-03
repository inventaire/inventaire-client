Search = require './views/search'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    SearchRouter = Marionette.AppRouter.extend
      appRoutes:
        'search': 'searchFromQueryString'

    app.addInitializer ->
      new SearchRouter
        controller: API

  initialize: ->
    app.commands.setHandlers
      'search:global': (query)->
        API.search(query)
        app.navigate "search?q=#{query}"

    app.reqres.setHandlers
      'search:entities': API.searchEntities

API = {}
API.search = (query)->
  app.search = searchLayout = new Search
    query: _.softDecodeURI(query)

  docTitle = "#{query} - " +  _.i18n('Search')
  app.layout.main.Show searchLayout, docTitle

API.searchFromQueryString = (querystring)->
  query = _.parseQuery(querystring).q
  API.search query
