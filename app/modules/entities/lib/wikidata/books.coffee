wd_ = require 'lib/wikidata'
books_ = require 'lib/books'

wdBooks_ = {}

wdBooks_.findIsbn = (claims)->
    isbn13 = _.stringOnly claims?.P957?[0]
    isbn10 = _.stringOnly claims?.P212?[0]
    isbn = isbn13 or isbn10
    if isbn? then return books_.normalizeIsbn(isbn)

wdBooks_.findAPictureByBookData = (bookModel)->
  if bookModel.get 'status.imageRequested'
    return _.log 'entity:picture:already requested'

  data = getMostAccurateData bookModel
  unless data?
    return _.log "entity:no data, no picture can be requested: #{@id}"

  requestImage bookModel, data

getMostAccurateData = (bookModel)->
  isbn = wdBooks_.findIsbn bookModel.claims
  if isbn? then return isbn
  else return getTitleAndAuthor bookModel

getTitleAndAuthor = (bookModel)->
  title = bookModel.get 'label'
  if title? and bookModel.claims?.P50?
    # look for Entities.byUri => assumes the entity data were already requested
    authors = app.request 'get:entities:labels', bookModel.claims.P50
    if authors?[0]?
      authors = authors.join ' '
      return "#{title} #{authors}"

requestImage = (bookModel, data)->
  eventName = books_.getImage(data)
  app.vent.once eventName, catchImage.bind(null, bookModel)

  bookModel.set('status.imageRequested', true)
  # saving the status, not the image
  bookModel.save()

catchImage = (bookModel, image)->
  if image?
    _.log image, "got it!!"
    bookModel.unshift('pictures', image)
    bookModel.save()

wdBooks_.fetchAuthorsEntities = (bookModel)->
  authors = bookModel.get('claims.P50')
  if authors?.length > 0
    return app.request('get:entities:models', 'wd', authors)
  else
    label = bookModel.get('label')
    _.warn "no author found for #{label}"
    return _.preq.resolve()

module.exports = wdBooks_