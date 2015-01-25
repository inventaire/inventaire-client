wd_ = require 'lib/wikidata'
books_ = require 'lib/books'

wdBooks_ = {}

wdBooks_.findIsbn = (claims)->
    isbn13 = _.stringOnly claims?.P957?[0]
    isbn10 = _.stringOnly claims?.P212?[0]
    isbn = isbn13 or isbn10
    if isbn? then return books_.normalizeIsbn(isbn)

wdBooks_.findAPictureByBookData = (bookModel)->
  _.log 'trying to findAPictureByBookData'
  unless bookModel.get('pictures')?[0]? or bookModel.get('status.imageRequested')

    isbn = wdBooks_.findIsbn(bookModel.claims)
    _.log isbn, 'isbn'
    if isbn? then data = isbn
    else
      label = bookModel.get('label')
      if label? and bookModel.claims?.P50?
        authors = app.request('get:entities:labels', bookModel.claims.P50)
        if authors?
          authors = authors.join ' '
          data = "#{label} #{authors}"


    _.log data, 'data'
    if data?
      eventName = books_.getImage(data)
      app.vent.once eventName, catchImage.bind(null, bookModel)
    else
      _.log "data:no data, no picture can be requested: #{@id}"

    bookModel.set('status.imageRequested', true)
    bookModel.save()

  else
    _.log 'entity:picture:already requested'

catchImage = (bookModel, res)->
  _.log res, "got it!!! #{data}"
  if res?.image?
    image = res.image
    pictures = [res.image]
    @set('pictures', pictures)
  _.log [bookModel.get('pictures'), bookModel], 'just requested a picture'


wdBooks_.fetchAuthorsEntities = (bookModel)->
    authors = bookModel.get('claims.P50')
    app.request('get:entities:models', 'wd', authors)

module.exports = wdBooks_