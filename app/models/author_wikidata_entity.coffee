WikidataEntity = require 'models/wikidata_entity'

module.exports = class AuthorWikidataEntity extends WikidataEntity
  specificInitializers: -> #noop to override on upgrade and avoid loops
  fetchAuthorsBooks: (limit)->
    @fetchAuthorsBooksIds()
    .then ()=> @fetchAuthorsBooksEntities()
    .fail (err)-> _.log err, 'fetchAuthorsBooks err'

  fetchAuthorsBooksIds: ->
    if @get('reverseClaims')?.P50? then $.Deferred().resolve()
    else
      numericId = @id.replace(/^Q/,'')
      # TODO: also fetch aliased Properties, not only P50
      $.getJSON _.proxy(wd.API.wmflabs.claim(50, numericId))
      .then (res)=>
        if res?.items?
          booksIds = wd.normalizeIds res.items
          _.log booksIds, 'booksIds'
          @set 'reverseClaims.P50', booksIds
          # almost useless to save yet as cached Author
          # will be overriden by the unformatted data
          # packaged in the entity search process
          @save()
      .fail (err)-> _.log err, 'fetchAuthorsBooksIds err'

  fetchAuthorsBooksEntities: ->
    authorsBooks = @get 'reverseClaims.P50'
    _.log authorsBooks, 'authorsBooks?'
    if authorsBooks?.length > 0
      Model = app.Model.AuthorWikidataEntity
      return Entities.tmp.wd.fetchModels authorsBooks, Model
    else $.Deferred().resolve()


  upgradeProperties: [
    'specificInitializers'
    'fetchAuthorsBooks'
    'fetchAuthorsBooksIds'
    'fetchAuthorsBooksEntities'
  ]