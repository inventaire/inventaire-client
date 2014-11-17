WikidataEntity = require 'models/wikidata_entity'
books = require 'lib/books'

module.exports = class BookWikidataEntity extends WikidataEntity
  specificInitializers: ->
    @findAPictureByBookData()
    @fetchAuthorsEntities()

  findAPictureByBookData: ->
    unless @get('status.imageRequested')
      label = @get('label')
      isbn13 = _.stringOnly @claims?.P957?[0]
      isbn10 = _.stringOnly @claims?.P212?[0]
      isbn = isbn13 or isbn10
      if isbn? then isbn = books.normalizeIsbn(isbn)
      data = isbn || label

      if data?
        books.getImage(data)
        .then (res)=>
          if res?.image?
            pictures = @get('pictures')
            pictures.unshift res.image
            @set('pictures', pictures)
          _.log [@get('pictures'), @], 'just requested a picture'
        .fail (err)-> _.logXhrErr err, "err after bookAPI.getImage for #{data}"
      else
        _.log [@get('pictures'), @], 'no data, no picture can be requested'

      @set('status.imageRequested', true)
      @save()

    else
      _.log 'picture already requested'

  fetchAuthorsEntities: ->
    authors = @get('claims.P50')
    authors?.forEach (authorId)->
      app.request('get:entity:model', "wd:#{authorId}")
      .fail (err)->
        _.log authors, 'fetchAuthorsEntities err for authors:'

  upgradeProperties: [
    'specificInitializers'
    'findAPictureByBookData'
    'fetchAuthorsEntities'
  ]