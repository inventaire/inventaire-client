module.exports = (global, _)->
  global.dbs =
    list: {}

  # DO NOT promisify method on LevelUp
  # As it messes with LevelMultiply
  Level = (dbName)-> LevelMultiply LevelUp(dbName, {db: LevelJs})

  reset = (db, dbName)->
    ops = []
    db.createKeyStream()
    .on 'data', pushKey.bind(null, ops)
    .on 'end', deleteBatch.bind(null, db, ops, dbName)

  pushKey = (ops, key)->
    _.log key, 'pushkey'
    ops.push {type: 'del', key: key}

  deleteBatch = (db, ops, dbName)->
    # cant use the promisified API.batch from here
    db.batch ops, (err)->
      if err then _.log err, "#{dbName} reset failed"
      else _.log "#{dbName} reset successfully!"

  dbs.reset = ->
    for dbName, db of dbs.list
      db.reset()

  return LocalDB = (dbName)->
    db = Level(dbName)
    API =
      get: Promise.promisify db.get
      put: Promise.promisify db.put
      batch: Promise.promisify db.batch
      reset: reset.bind(null, db, dbName)
      db: db

    return dbs.list[dbName] = API