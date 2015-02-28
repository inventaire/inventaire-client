wd_ = require 'lib/wikidata'
books_ = require 'lib/books'

wdBooks_ = {}

wdBooks_.findIsbn = (claims)->
    isbn13 = _.stringOnly claims?.P957?[0]
    isbn10 = _.stringOnly claims?.P212?[0]
    isbn = isbn13 or isbn10
    if isbn? then return books_.normalizeIsbn(isbn)

wdBooks_.findAPictureByBookData = (bookModel)->
  unless bookModel.get('status.imageRequested')
    isbn = wdBooks_.findIsbn(bookModel.claims)
    if isbn? then data = isbn
    else
      label = bookModel.get('label')
      if label? and bookModel.claims?.P50?
        authors = app.request('get:entities:labels', bookModel.claims.P50)
        if authors?[0]?
          authors = authors.join ' '
          data = "#{label} #{authors}"


    if data?
      eventName = books_.getImage(data)
      app.vent.once eventName, catchImage.bind(null, bookModel)
    else
      _.log "data:no data, no picture can be requested: #{@id}"

    bookModel.set('status.imageRequested', true)
    bookModel.save()

  else
    _.log 'entity:picture:already requested'

catchImage = (bookModel, image)->
  if image?
    _.log image, "got it!!"
    bookModel.unshift('pictures', image)

wdBooks_.fetchAuthorsEntities = (bookModel)->
    authors = bookModel.get('claims.P50')
    if authors?.length > 0
      return app.request('get:entities:models', 'wd', authors)
    else return _.preq.reject('no author found at fetchAuthorsEntities')

module.exports = wdBooks_