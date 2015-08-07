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
    [newRoute, newQuery] = newRoute.split '?'
    newQuery = _.parseQuery newQuery
    # keep query elements for certain route sections
    # typically: keep redirect parameter for signup/login routes
    if _.routeSection(newRoute) in sectionAllowPersistantQuery
      # get info on current query
      currentQuery = getQuery()
      # keep only whitelisted persistant parameters
      currentQuery = _.pick currentQuery, persistantQuery
      # extend persisting current parameters with new parameters
      newQuery = _.extend currentQuery, newQuery
    return _.buildPath(newRoute, newQuery)


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

persistantQuery = [
  'redirect'
]

sectionAllowPersistantQuery = [
  'signup'
  'login'
]
