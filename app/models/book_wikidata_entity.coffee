WikidataEntity = require 'models/wikidata_entity'

module.exports = class BookWikidataEntity extends WikidataEntity
  specificInitializers: ->
    @findAPictureByBookData()

  findAPictureByBookData: ->
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
      .fail (err)-> _.log err, "err after bookAPI.getImage for #{data}"
      .done()