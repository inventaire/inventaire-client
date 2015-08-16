Search = require './views/search'
error_ = require 'lib/error'

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
      'search:global': API.search

    app.reqres.setHandlers
      'search:entities': API.searchEntities

API = {}
API.search = (query)->
  unless _.isNonEmptyString query
    app.execute 'show:add:layout'
    return

  app.search = searchLayout = new Search
    query: _.softDecodeURI(query)

  docTitle = "#{query} - " +  _.i18n('Search')
  app.layout.main.Show searchLayout, docTitle
  app.navigate "search?q=#{query}"

API.searchFromQueryString = (querystring)->
  { q } = _.parseQuery querystring
  API.search q
