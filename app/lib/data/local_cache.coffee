# LocalCache REQUIRES
# - name: a domain name
# - remote.get: a function to get batches of missing data by ids
# => SHOULD output an indexed collection: {id1: {val}, id2: {val}}
# - parseData: a function to parse the remote.get


# RETURNS
# an object with a .get function checking local before remote
# .get:
#     accepts both id:String or ids:Array
#     always return an index {id1: value, id2: value}
#

module.exports = (LocalDB, _, promises_)->

  LocalCache = (options)->
    _.log options, 'cache:options'
    {name, remote, normalizeId, parseData} = options

    args = [name, remote, normalizeId, parseData]
    types = ['string', 'object', 'function|undefined', 'function|undefined']
    _.types args, types

    localdb = LocalDB(name)

    defaultParser = (data)-> data
    parseData or= defaultParser


    API =
      get: (ids, format, refresh)->
        try ids = _.forceArray(ids)
        catch err then return Promise.reject(err)

        if ids.length is 0
          promise = _.preq.resolve {}
        else if refresh
          promise = getMissingData(ids)
        else
          promise = getLocalData(ids).then completeWithRemoteData

        return promise
        .then formatData.bind(null, format)
        .catch logError

      save: (id, value)->
        _.types arguments, ['string', 'object']
        _.log "cache:saving #{id}"
        putInLocalDb id, value

      reset: -> localdb.destroy()
      db: localdb

    getLocalData = (ids)->
      _.types ids, 'strings...'
      if normalizeId? then ids = ids.map normalizeId

      # _.type ids, 'array' already asserted by _.forceArray
      localdb.get(ids)
      .then parseJSON
      .then _.Log("cache:#{name} present")

    parseJSON = (data)->
      # LevelJs returns a json string per item
      # while LevelMultiply regroup them in an id-based index object
      # thus requiring every value to be JSON.parse'd
      _.type data, 'object'
      parsed = {}
      for k,v of data
        try parsed[k] = JSON.parse(v)
        catch err then _.error "invalid json: #{v}"
      return parsed

    completeWithRemoteData = (data)->
      _.type data, 'object'
      missingIds = findMissingIds(data)
      if missingIds.length > 0
        getMissingData(missingIds)
        .then (missingData)-> return _.extend data, missingData
      else return data

    findMissingIds = (data)->
      _.type data, 'object'
      missingIds = []
      for k, v of data
        missingIds.push(k)  unless v?

      if missingIds.length > 0
        _.log missingIds, "cache:#{name} missingIds"
      return missingIds

    getMissingData = (ids)->
      _.type ids, 'array'
      # which MUST return a {id1: value2, id2: value2, ...} object
      promise = remote.get(ids).then parseData

      unless promise?.then? then throw new Error('couldnt get missing data')

      # cachedData is listening to the remote data
      # but doesn't need to be returned elsewhere
      promise.then putLocalData
      return promise

    putLocalData = (data)->
      _.type data, 'object'
      for id, v of data
        putInLocalDb(id,v)
      return data

    putInLocalDb = (id, value)->
      _.types arguments, ['string', 'object']
      localdb.put id, JSON.stringify(value)
      return value

    formatData = (format='index', data)->
      _.type data, 'object'
      if format is 'collection' then data = _.values(data)
      return _.log data, "cache:format:#{format}"

    logError = (err)->
      _.error err, 'local cache err'
      return


    if remote.post?
      API.post = (data)->
        remote.post(data)
        .then (res)->
          _.log res, "cache:#{name}:post res"
          id = findId(res)
          putInLocalDb id, res
        .catch (err)-> _.error err, "#{name} local.post err"

      findId = (res)->
        id = res._id or res.id
        if id? then return id
        else throw new Error "id not found: #{JSON.stringify(res)}"

    _.extend @, API
    return