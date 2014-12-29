WikidataEntity = require './wikidata_entity'
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
      data = isbn or label
      console.log 'data', data, 'isbn', isbn, 'isbn10', isbn10, 'isbn13', isbn13

      if data?
        books.getImage(data)
        app.vent.once "image:#{data}", (res)=>
          if res?.image?
            pictures = @get('pictures')
            pictures.push res.image
            @set('pictures', pictures)
          _.log [@get('pictures'), @], 'just requested a picture'
      else
        _.log [@get('pictures'), @], 'no data, no picture can be requested'

      @set('status.imageRequested', true)
      @save()

    else
      _.log 'entity:picture:already requested'

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