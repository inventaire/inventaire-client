WikidataEntity = require 'models/wikidata_entity'

module.exports = class AuthorWikidataEntity extends WikidataEntity
  fetchAuthorsBooks: ->
    @fetchAuthorsBooksIds()
    .then ()=> @fetchAuthorsBooksEntities()
    .fail (err)-> _.log err, 'fetchAuthorsBooks err'

  fetchAuthorsBooksIds: ->
    numericId = @id.replace(/^Q/,'')
    $.getJSON _.proxy(wd.API.wmflabs.claim(50, numericId))
    .then (res)=>
      if res?.items?
        booksIds = wd.normalizeIds res.items
        _.log booksIds, 'booksIds'
        @set 'reverseClaims.P50', booksIds
    .fail (err)-> _.log err, 'fetchAuthorsBooksIds err'

  fetchAuthorsBooksEntities: ->
    authorsBooks = @get 'reverseClaims.P50'
    _.log authorsBooks, 'authorsBooks?'
    if authorsBooks?.length > 0
      Model = app.Model.AuthorWikidataEntity
      return Entities.tmp.wd.fetchModels authorsBooks, Model
    else $.Deferred().resolve()