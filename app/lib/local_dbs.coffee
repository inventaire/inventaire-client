module.exports =
  initialize: ->
    window.Level = (dbName)->
      db = LevelUp(dbName, {db: LevelJs})
      return LevelPromise(LevelMultiply(db))