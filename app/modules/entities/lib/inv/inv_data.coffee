localCache = require 'lib/data/local_cache'

module.exports = (app, _)->
  remote =
    get: (ids)->
      _.preq.get app.API.entities.inv.get(ids)
      .catch _.ErrorRethrow('inv_data get err')
    post: (body)->
      url = app.API.entities.inv.create
      _.preq.post(url, body)
      .catch _.ErrorRethrow('inv_data post err')

  local = localCache
    name: 'entities_inv'
    remote: remote
    # parseData: _.Log('inv parseData')


  return invData =
    local: local
    remote: remote
