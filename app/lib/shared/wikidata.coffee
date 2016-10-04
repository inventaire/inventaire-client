{ Q, types } = require './wikidata_aliases'

module.exports = (promises_, _, wdk)->
  API = require('./wikidata_api')(_)

  unprefix = (value)-> value.replace 'wd:', ''
  addPrefixes = (value)-> "wd:#{value}"

  getType = (P31Array, missPrefixes)->
    unless P31Array? then return

    if missPrefixes then P31Array = P31Array.map addPrefixes

    for value in P31Array
      type = types[value]
      # return as soon as we get a type
      if type? then return type

    _.warn P31Array, 'type not found'
    return

  return {
    API: API
    getType: getType
    unprefix: unprefix
    getEntities: (ids, languages, props)->
      url = wdk.getEntities ids.map(unprefix), languages, props
      return promises_.get url

    getUri: (id)-> 'wd:' + wdk.normalizeId(id)
    isAuthor: (P106Array=[])-> _.haveAMatch Q.authors, P106Array

    wmCommonsSmallThumb: (file, width="100")->
      file = _.fixedEncodeURIComponent file
      "https://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

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
    }
