cache = {}

module.exports = (entity)->
  { pluralizedType: type } = entity
  if cache[type]?
    Promise.resolve cache[type]
  else
    _.preq.get(app.API.data.entityTypeAliases(type))
    .then (res)->
      aliases = res['entity-type-aliases']
      cache[type] = aliases
      return aliases
