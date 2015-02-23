module.exports = (app, _)->

  queryString = (option)->
    query = _.parseQuery location.href.split('?')[1]
    return query?[option]


  app.reqres.setHandlers
    'route:querystring': queryString