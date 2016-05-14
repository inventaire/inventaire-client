allowPersistantQuery = require './allow_persistant_query'

module.exports = (app, _)->

  get = (key)-> getQuery()?[key]

  set = (key, value)->
    pathname = getPathname()
    query = getQuery()
    query[key] = value

    fullPath = _.buildPath(pathname, query)
    app.navigateReplace fullPath

  # report persistant querystrings from the current route to the next one
  keep = (newRoute)->
    # get info on new route
    [ newRoute, newQuery ] = newRoute.split '?'
    newQuery = _.parseQuery newQuery

    currentQuery = getQuery()
    keptQuery = {}

    newRouteSection = _.routeSection newRoute

    for k, v of currentQuery
      test = allowPersistantQuery[k]
      # discard queries that have no tests in allowPersistantQuery
      if test?(newRouteSection)
        keptQuery[k] = v

    # extend persisting current parameters with new parameters
    newQuery = _.extend keptQuery, newQuery
    return _.buildPath newRoute, newQuery

  getPathname = ->
    # remove the first character: '/'
    window.location.pathname.slice(1)

  getQuery = ->
    # remove the first character '/', and return as an object
    _.parseQuery window.location.search.slice(1)

  app.reqres.setHandlers
    'route:querystring:get': get
    'route:querystring:keep': keep

  app.commands.setHandlers
    'route:querystring:set': set
