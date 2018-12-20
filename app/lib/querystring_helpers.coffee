allowPersistantQuery = require './allow_persistant_query'
{ parseQuery, buildPath, setQuerystring, routeSection } = require 'lib/location'

module.exports = (app, _)->
  app.reqres.setHandlers
    'querystring:get': get
    'querystring:get:full': getQuery
    'querystring:keep': keep

  app.commands.setHandlers
    'querystring:set': set

get = (key)->
  value = getQuery()?[key]
  switch value
    # Parsing boolean string
    when 'true' then true
    when 'false' then false
    else value

set = (key, value)->
  # Setting the value to 'null' and not just null allows to have the null value
  # passed to the keep function (called by app.navigate), thus unsetting
  # the desired key
  unless value? then value = 'null'

  # omit the first character: '/'
  currentPath = window.location.pathname.slice(1) + window.location.search
  updatedPath = setQuerystring currentPath, key, value
  app.navigateReplace updatedPath

# report persistant querystrings from the current route to the next one
keep = (newRoute)->
  # get info on new route
  [ newRoute, newQuery ] = newRoute.split '?'
  newQuery = parseQuery newQuery

  currentQuery = getQuery()
  keptQuery = {}

  newRouteSection = routeSection newRoute

  for k, v of currentQuery
    test = allowPersistantQuery[k]
    # discard queries that have no tests in allowPersistantQuery
    if test?(newRouteSection)
      keptQuery[k] = v

  # extend persisting current parameters with new parameters
  newQuery = _.extend keptQuery, newQuery
  return buildPath newRoute, newQuery

getQuery = -> parseQuery window.location.search
