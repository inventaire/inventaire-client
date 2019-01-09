Searches = require './collections/searches'
SearchLayout = require './views/search'
error_ = require 'lib/error'
findUri = require './lib/find_uri'
{ parseQuery } = require 'lib/location'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'search(/)': 'searchFromQueryString'

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

  if showEntityPageIfUri(query, refresh) then return

  # Else, show the normal search layout
  app.layout.main.show new SearchLayout { query, refresh }

  encodedQuery = _.fixedEncodeURIComponent query
  app.navigate "search?q=#{encodedQuery}",
    metadata: { title: "#{query} - " +  _.I18n('search') }

API.searchFromQueryString = (querystring)->
  { q, refresh } = parseQuery querystring
  refresh = _.parseBooleanString refresh
  # Replacing "+" added that the browser search might have added
  q = q.replace /\+/g, ' '

  if showEntityPageIfUri(q, refresh) then return

  [ q, section ] = findSearchSection q

  # Forwarding to the top bar live search instead of directly calling API.search
  # as the live search is way faster, and from their the full search,
  # if needed, is one click away
  app.vent.trigger 'live:search:query',
    search: q
    section: section
    # Show the add layout at its search tab in the background, so that clicking
    # out of the live search doesn't result in a blank page
    showFallbackLayout: app.Execute 'show:add:layout:search'

showEntityPageIfUri = (query, refresh)->
  # If the query text is a URI, show the associated entity page
  # as it doesn't make sense to search for an entity we have already found
  uri = findUri query
  if uri?
    app.execute 'show:entity', uri, { refresh }
    return true
  else
    return false

sectionSearchPattern = /(s|section):(\w+)/

findSearchSection = (q)->
  sectionMatch = q.match(sectionSearchPattern)?[2]
  unless sectionMatch? then return [ q, 'all' ]

  q = q.replace(sectionSearchPattern, '').trim()

  # Work around the conflict with series of the 's' key
  if sectionMatch.match /^subjects?$/ then return [ q, 'subjects' ]

  firstLetter = sectionMatch[0]
  section = sections[firstLetter] or 'all'
  return [ q, section ]

sections =
  b: 'book'
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
