LevelMultiply = require 'level-multiply'
LevelJs = require 'level-js'
resetDbsPeriodically = require './reset_dbs_periodically'

DB = null

module.exports =
  init: ->
    if window.supportsIndexedDB
      DB = LevelJs
      console.log 'supportsIndexedDB true: using LevelJs'

      # delayed to let the app the time to start up.
      # only needed when using LevelJs/indexeddb
      setTimeout resetDbsPeriodically, 10*1000

      return Promise.resolve()

    else
      # requiring those as app.API and _.preq aren't available yet
      scriptsAPI = require 'api/scripts'
      preq = require 'lib/preq'

      console.log 'supportsIndexedDB false: fetching MemDown'

      preq.getScript scriptsAPI.memdown()
      .then -> DB = MemDown

  build: (global, _)->
    global.dbs =
      list: {}

    # let the possibility to inject a different LevelUp upstream for tests
    global.LevelUp or= require 'levelup'

    # DO NOT promisify method on LevelUp
    # As it messes with LevelMultiply
    Level = (dbName)->
      LevelMultiply LevelUp(dbName, {db: DB})

    reset = (db, dbName)->
      return new Promise (resolve, reject)->
        ops = []
        db.createKeyStream()
        .on 'data', pushKey.bind(null, ops)
        .on 'error', reject
        .on 'end', -> resolve deleteBatch(db, ops, dbName)

    inspect = (db, dbName)->
      dbObj = {}
      db.createReadStream()
      .on 'data', (res)->
        { key, value } = res
        _.log JSON.parse(value), key
      .on 'end', _.Log("-- #{dbName} inspect end")

    pushKey = (ops, key)->
      # _.log key, 'pushkey'
      ops.push {type: 'del', key: key}

    deleteBatch = (db, ops, dbName)->
      db.customApi.batch ops
      .then -> _.log "#{dbName} reset successfully!"
      .catch _.ErrorRethrow("#{dbName} reset failed")

    dbs.reset = -> Promise.all _.invoke(_.values(dbs.list), 'reset')
    dbs.inspect = -> db.inspect()  for dbName, db of dbs.list

    return LocalDB = (dbName)->
      db = Level(dbName)
      API =
        get: Promise.promisify db.get, { context: db }
        put: Promise.promisify db.put, { context: db }
        batch: Promise.promisify db.batch, { context: db }
        reset: reset.bind(null, db, dbName)
        inspect: inspect.bind(null, db, dbName)
        db: db

      db.customApi = API
      dbs.list[dbName] = API
      return API
