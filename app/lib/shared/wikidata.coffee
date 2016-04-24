{ Q } = require './wikidata_aliases'

module.exports = (promises_, _, wdk)->
  API = require('./wikidata_api')(_)

  return helpers =
    API: API
    getEntities: (ids, languages, props)->
      url = wdk.getEntities ids, languages, props
      return promises_.get url

    getUri: (id)-> 'wd:' + wdk.normalizeId(id)
    isBook: (P31Array=[])-> _.haveAMatch Q.books, P31Array
    isArticle: (P31Array=[])-> _.haveAMatch Q.articles, P31Array=[]
    entityIsBook: (entity)-> helpers.isBook entity.claims.P31
    entityIsArticle: (entity)-> helpers.isArticle entity.claims.P31
    isAuthor: (P106Array=[])-> _.haveAMatch Q.authors, P106Array
    isHuman: (P31Array=[])-> _.haveAMatch Q.humans, P31Array
    isGenre: (P31Array=[])-> _.haveAMatch Q.genres, P31Array
    type: (entity)->
      if _.isModel entity then P31 = entity.get?('claims')?.P31
      else P31 = entity.claims?.P31
      if P31?
        if @isBook P31 then return 'book'
        if @isArticle P31 then return 'article'
        if @isHuman P31 then return 'human'
        if @isGenre P31 then return 'genre'

    wmCommonsSmallThumb: (file, width="100")->
      file = encodeURIComponent file
      "https://commons.wikimedia.org/w/thumb.php?width=#{width}&f=#{file}"
