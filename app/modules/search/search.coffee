SearchResultsHistory = require './collections/search_results_history'
findUri = require './lib/find_uri'
{ parseQuery } = require 'lib/location'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'search(/)': 'searchFromQueryString'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.searchResultsHistory = new SearchResultsHistory

    app.commands.setHandlers
      'search:global': API.search

    app.reqres.setHandlers
      'search:entities': API.searchEntities
      'search:history:add': (data)-> app.searchResultsHistory.addNonExisting data

API = {}
API.search = (search, section, showFallbackLayout)->
  app.vent.trigger 'live:search:query', { search, section, showFallbackLayout }

API.searchFromQueryString = (querystring)->
  { q, refresh } = parseQuery querystring
  refresh = _.parseBooleanString refresh
  # Replacing "+" added that the browser search might have added
  q = q.replace /\+/g, ' '

  if showEntityPageIfUri(q, refresh) then return

  [ q, section ] = findSearchSection q

  # Show the add layout at its search tab in the background, so that clicking
  # out of the live search doesn't result in a blank page
  showFallbackLayout = app.Execute 'show:add:layout:search'

  API.search q, section, showFallbackLayout

showEntityPageIfUri = (query, refresh)->
  # If the query text is a URI, show the associated entity page
  # as it doesn't make sense to search for an entity we have already found
  uri = findUri query
  if uri?
    app.execute 'show:entity', uri, { refresh }
    return true
  else
    return false

sectionSearchPattern = /^!([blwahsugt])\s+/

findSearchSection = (q)->
  sectionMatch = q.match(sectionSearchPattern)?[1]
  unless sectionMatch? then return [ q, 'all' ]

  q = q.replace(sectionSearchPattern, '').trim()

  firstLetter = sectionMatch[0]
  section = sections[firstLetter] or 'all'
  return [ q, section ]

sections =
  b: 'book'
  # 'l' for livre, libro, liber
  l: 'book'
  # 'w' for work
  w: 'book'
  a: 'author'
  # 'h' for human
  h: 'author'
  s: 'serie'
  u: 'user'
  g: 'group'
  # 't' for topic (as series already use the 's')
  t: 'subject'
