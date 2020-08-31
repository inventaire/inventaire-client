cache = {}

module.exports = (entity)->
  { pluralizedType: type } = entity
  if cache[type]?
    Promise.resolve cache[type]
  else
    _.preq.get(app.API.data.aliases(type))
    .then (values)->
      cache[type] = values
      return values
