{ Q, types } = require './wikidata_aliases'

module.exports = (promises_, _, wdk)->
  API = require('./wikidata_api')(_)

  unprefixify = (value)-> value.replace 'wd:', ''

  getType = (P31Array)->
    unless P31Array? then return

    for value in P31Array
      type = types[value]
      # return as soon as we get a type
      if type? then return type

    _.warn P31Array, 'type not found'
    return

  return helpers =
    API: API
    getType: getType
    getEntities: (ids, languages, props)->
      url = wdk.getEntities ids.map(unprefixify), languages, props
      return promises_.get url

    isAuthor: (P106Array=[])-> _.haveAMatch Q.authors, P106Array

    # Takes an entity model
    # Returns a entity type string: book, edition, article, human, genre
    type: (entity)->
      if entity.type then return entity.type
      if _.isModel entity then claims = entity.get?('claims')
      else { claims } = entity

      unless claims? then return

      P31Array = claims.P31 or claims['wdt:P31']

      entity.type = getType P31Array
      return entity.type
