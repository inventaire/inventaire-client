module.exports = (dbName)->
  db = LevelUp(dbName, {db: LevelJs})
  return LevelPromise(LevelMultiply(db))