allowPersistantQuery = require './allow_persistant_query'

module.exports = (app, _)->

  get = (key)->
    value = getQuery()?[key]
    switch value
      # Parsing boolean string
      when 'true' then true
      when 'false' then false
      else value

  set = (key, value)->
    # omit the first character: '/'
    currentPath = window.location.pathname.slice(1) + window.location.search
    updatedPath = _.setQuerystring currentPath, key, value
    app.navigateReplace updatedPath

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

  getQuery = -> _.parseQuery window.location.search

  app.reqres.setHandlers
    'querystring:get': get
    'querystring:keep': keep

  app.commands.setHandlers
    'querystring:set': set
