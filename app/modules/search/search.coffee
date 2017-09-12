Searches = require './collections/searches'
SearchLayout = require './views/search'
error_ = require 'lib/error'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'search': 'searchFromQueryString'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.commands.setHandlers
      'search:global': API.search

    app.reqres.setHandlers
      'search:entities': API.searchEntities

    # keep an history of searches
    app.searches = new Searches

API = {}
API.search = (query, refresh)->
  unless _.isNonEmptyString query
    app.execute 'show:add:layout:search'
    return

  app.layout.main.show new SearchLayout { query, refresh }

  encodedQuery = _.fixedEncodeURIComponent query
  app.navigate "search?q=#{encodedQuery}",
    metadata: { title: "#{query} - " +  _.I18n('search') }

API.searchFromQueryString = (querystring)->
  { q, refresh } = _.parseQuery querystring
  refresh = _.parseBooleanString refresh
  # Replacing "+" added that the browser search might have added
  q = q.replace /\+/g, ' '
  # Forwarding to the top bar live search instead of directly calling API.search
  # as the live search is way faster, and from their the full search,
  # if needed, is one click away
  app.vent.trigger 'live:search:query', q
