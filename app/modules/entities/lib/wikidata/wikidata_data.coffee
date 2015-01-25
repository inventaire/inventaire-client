module.exports = (app, _, wd, promises_)->
  remote =
    get: (ids)-> wd.getEntities(ids, app.user.lang)

  local = new app.LocalCache
    name: 'entities_wd'
    remoteDataGetter: remote.get
    parseData: (data)-> _.log data.entities, 'wd parseData'

  return wdData =
    local: local
    remote: remote