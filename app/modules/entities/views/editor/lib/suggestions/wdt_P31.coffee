module.exports = (entity)->
  type = entity.pluralizedType
  return _.preq.get(app.API.data.aliases(type))
