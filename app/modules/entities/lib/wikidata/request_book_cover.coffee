books_ = require 'lib/books'

module.exports = (bookModel)->
  data = getMostAccurateData bookModel
  entityUri = bookModel.get 'uri'

  books_.getImage entityUri, data
  .then attachPictures.bind(null, bookModel)
  .catch _.Error('requestBookCover')

  bookModel.set 'status.imageRequested', true
  # saving the status, not the image
  bookModel.save()

# when no picture is found from the entity uri
# data collected here will serve to search by text
getMostAccurateData = (bookModel)->
  isbn = findIsbn bookModel.claims
  if isbn? then return isbn
  else return getTitleAndAuthor bookModel

findIsbn = (claims)->
  isbn13 = _.stringOnly claims?.P957?[0]
  isbn10 = _.stringOnly claims?.P212?[0]
  isbn = isbn13 or isbn10
  if isbn? then return books_.normalizeIsbn isbn

getTitleAndAuthor = (bookModel)->
  title = bookModel.get 'label'
  if title? and bookModel.claims?.P50?
    # look for Entities.byUri => assumes the entity data were already requested
    authors = app.request 'get:entities:labels', bookModel.claims.P50
    if authors?[0]?
      authors = authors.join ' '
      return "#{title} #{authors}"

attachPictures = (bookModel, pictures)->
  _.types pictures, 'objects...'
  if pictures.length > 0
    pics = bookModel.get('pictures') or []
    # putting new pictures first in the list
    pictures = pictures.map _.property('image')
    bookModel.set 'pictures', pictures.concat(pics)
    bookModel.save()
