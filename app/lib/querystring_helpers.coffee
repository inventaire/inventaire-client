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


  app.reqres.setHandlers
    'route:querystring:get': get

  app.commands.setHandlers
    'route:querystring:set': set


getPath = ->
  location.href
  # take the part after location.origin
  .split(location.origin)[1]
  # remove the first character: '/'
  .slice(1)
