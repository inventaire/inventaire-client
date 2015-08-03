resetDbsPeriodically = require './reset_dbs_periodically'

module.exports = (global, _)->
  global.dbs =
    list: {}

  if window.supportsIndexedDB
    DB = LevelJs
    _.log 'supportsIndexedDB true: using LevelJs'

    # delayed to let the app the time to start up.
    # only needed when using LevelJs/indexeddb
    setTimeout resetDbsPeriodically, 10*1000

  else
    DB = MemDown
    _.log 'supportsIndexedDB false: using MemDown'



  # DO NOT promisify method on LevelUp
  # As it messes with LevelMultiply
  Level = (dbName)->
    LevelMultiply LevelUp(dbName, {db: DB})

  reset = (db, dbName)->
    ops = []
    db.createKeyStream()
    .on 'data', pushKey.bind(null, ops)
    .on 'end', deleteBatch.bind(null, db, ops, dbName)

  inspect = (db, dbName)->
    dbObj = {}
    db.createReadStream()
    .on 'data', (res)->
      {key, value} = res
      _.log JSON.parse(value), key
    .on 'end', _.Log("-- #{dbName} inspect end")

  pushKey = (ops, key)->
    # _.log key, 'pushkey'
    ops.push {type: 'del', key: key}

  deleteBatch = (db, ops, dbName)->
    # cant use the promisified API.batch from here
    db.batch ops, (err)->
      if err then _.log err, "#{dbName} reset failed"
      else _.log "#{dbName} reset successfully!"

  dbs.reset = -> db.reset()  for dbName, db of dbs.list
  dbs.inspect = -> db.inspect()  for dbName, db of dbs.list

  return LocalDB = (dbName)->
    db = Level(dbName)
    API =
      get: Promise.promisify db.get
      put: Promise.promisify db.put
      batch: Promise.promisify db.batch
      reset: reset.bind(null, db, dbName)
      inspect: inspect.bind(null, db, dbName)
      db: db

    return dbs.list[dbName] = API