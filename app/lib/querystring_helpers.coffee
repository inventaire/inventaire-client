module.exports = (app, _)->

  getRouteQuery = ->
    [route, query] = getPath().split('?')
    query = _.parseQuery(query)
    return [route, query]

  setRouteQuery = (route, query)->
    path = _.buildPath(route, query)
    app.navigateReplace path


  get = (key)->
    [route, query] = getRouteQuery()
    return query?[key]

  set = (key, value)->
    _.types arguments, 'strings...'

    [route, query] = getRouteQuery()
    query[key] = value
    setRouteQuery route, query

  # report querystrings from the current route to the next one
  keep = (newRoute)->
    # get info on current route
    [currentRoute, currentQuery] = getRouteQuery()
    # get info on new route
    [newRoute, newQuery] = newRoute.split('?')
    newQuery = _.parseQuery(newQuery)
    # extend current query with new query
    newQuery = _.extend currentQuery, newQuery
    return _.buildPath(newRoute, newQuery)


  getPath = ->
    location.href
    # take the part after location.origin
    .split(location.origin)[1]
    # remove the first character: '/'
    .slice(1)

  app.reqres.setHandlers
    'route:querystring:get': get
    'route:path:get': getPath
    'route:querystring:keep': keep

  app.commands.setHandlers
    'route:querystring:set': set
