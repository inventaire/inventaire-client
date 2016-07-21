{ Q } = require './wikidata_aliases'

module.exports = (promises_, _, wdk)->
  API = require('./wikidata_api')(_)

  IsType = (aliases)->
    return isType = (P31Array=[])-> _.haveAMatch aliases, P31Array

  helpers =
    API: API
    getEntities: (ids, languages, props)->
      url = wdk.getEntities ids, languages, props
      return promises_.get url

    getUri: (id)-> 'wd:' + wdk.normalizeId(id)
    isBook: IsType Q.books
    isEdition: IsType Q.edition
    isArticle: IsType Q.articles
    isHuman: IsType Q.humans
    isGenre: IsType Q.genres
    isAuthor: (P106Array=[])-> _.haveAMatch Q.authors, P106Array
    entityIsBook: (entity)-> helpers.isBook entity.claims.P31
    entityIsArticle: (entity)-> helpers.isArticle entity.claims.P31

    wmCommonsSmallThumb: (file, width="100")->
      file = encodeURIComponent file
      "https://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"

  unprefix = (value)-> value.replace 'wd:', ''

  helpers.type = (entity)->
    if _.isModel entity then claims = entity.get?('claims')
    else { claims } = entity

    unless claims? then return

    P31 = claims.P31 or claims['wdt:P31']
    unless P31? then return
    P31 = P31.map unprefix
    console.log('P31', P31)

    if helpers.isBook P31 then return 'book'
    if helpers.isEdition P31 then return 'edition'
    if helpers.isArticle P31 then return 'article'
    if helpers.isHuman P31 then return 'human'
    if helpers.isGenre P31 then return 'genre'

    _.warn entity, 'entity type not found'
    return

  return helpers