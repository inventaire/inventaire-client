Level = require('lib/local_dbs')

module.exports = LocalCache = (options)->

  {name, remoteDataGetter, parseData} = options

  unless name? and remoteDataGetter?
    throw 'missing localDb or remoteDataGetter'

  localDb = Level(name)

  defaultParser = (data)-> data
  parseData or= defaultParser


  API =
    get: (ids, format='index', refresh)->
      ids = normalizeIds(ids)
      if refresh
        promise = getMissingData(ids)
      else
        promise = getLocalData(ids).then completeWithRemoteData

      promise
      .then (data)->
        if format is 'collection' then data = _.values(data)
        _.log data, "data:format:#{format}"
      .catch (err)->
        _.log err, 'get err'
        throw new Error('get', err.stack or err)

  normalizeIds = (ids)->
    if _.isString(ids) then ids = [ids]
    return ids

  getLocalData = (ids)->
    localDb.get(ids)
    .then parseJSON

  parseJSON = (data)->
    parsed = {}
    for k,v of data
      try parsed[k] = JSON.parse(v)
      catch err then _.error "invalid json: #{v}"
    return parsed

  completeWithRemoteData = (data)->
    missingIds = findMissingIds(data)
    if missingIds.length > 0
      getMissingData(missingIds)
      .then (missingData)-> return _.extend data, missingData
    else return data

  findMissingIds = (data)->
    missingIds = []
    for k, v of data
      missingIds.push(k)  unless v?
    return missingIds

  getMissingData = (ids)->
    console.warn "remoteDataGetter MUST return a then'able Promise"
    console.warn "CANT BE DONE WITH JQUERY"
    console.warn "a solution could be to move to ES6 Promise + polyfill"
    # which MUST return a {id1: value2, id2: value2, ...} object
    promise = remoteDataGetter(ids).then parseData

    unless promise?.then? then throw 'couldnt get missing data'

    # cachedData is listening to the remote data
    # but doesn't need to be returned elsewhere
    promise.then putLocalData
    return promise

  putLocalData = (data)->
    for id, v of data
      putInLocalDb(id,v)

  putInLocalDb = (id, value)->
    localDb.put id, JSON.stringify(value)

  _.extend @, API
  return