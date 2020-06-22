SearchResultsHistory = require './collections/search_results_history'
findUri = require './lib/find_uri'
{ parseQuery } = require 'lib/location'
{ setPrerenderStatusCode } = require 'lib/metadata/update'

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
      'show:users:search': -> API.search '', 'user'
      'show:groups:search': -> API.search '', 'group'

    app.reqres.setHandlers
      'search:entities': API.searchEntities
      'search:history:add': (data)-> app.searchResultsHistory.addNonExisting data

API = {}
API.search = (search, section, showFallbackLayout)->
  # Prevent indexation of search pages, by making them appear as duplicates of the home
  setPrerenderStatusCode 302, ''
  app.vent.trigger 'live:search:query', { search, section, showFallbackLayout }

API.searchFromQueryString = (querystring)->
  { q, type, refresh } = parseQuery querystring
  refresh = _.parseBooleanString refresh
  q ?= ''
  # Replacing "+" added that the browser search might have added
  q = q.replace /\+/g, ' '

  if showEntityPageIfUri(q, refresh) then return

  if type? then section = type
  else [ q, section ] = findSearchSection q

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

sectionSearchPattern = /^!([a-z])\s+/

findSearchSection = (q)->
  sectionMatch = q.match(sectionSearchPattern)?[1]
  unless sectionMatch? then return [ q, 'all' ]

  q = q.replace(sectionSearchPattern, '').trim()

  firstLetter = sectionMatch[0]
  section = sections[firstLetter] or 'all'
  console.log 'section', section
  return [ q, section ]

sections =
  a: 'author'
  b: 'book'
  c: 'collection'
  g: 'group'
  h: 'author' # 'h' for human
  l: 'book' # 'l' for livre, libro, liber
  p: 'publisher'
  s: 'serie'
  t: 'subject' # 't' for topic (as series already use the 's')
  u: 'user'
  w: 'book' # 'w' for work
