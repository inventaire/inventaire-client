module.exports = ->
  { groups } = app.user

  app.reqres.setHandlers
    'get:group:model': (id)-> _.preq.resolve groups.byId(id)
    'get:group:model:sync': groups.byId.bind(groups)

