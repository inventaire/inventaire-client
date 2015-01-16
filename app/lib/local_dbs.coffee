window.dbs = {}

# DO NOT promisify method on LevelUp
# As it messes with LevelMultiply
Level = (dbName)-> LevelMultiply LevelUp(dbName, {db: LevelJs})

module.exports = (dbName)->
  db = Level(dbName)
  API =
    get: Promise.promisify db.get
    put: Promise.promisify db.put
    db: db

  return dbs[dbName] = API
