books_ = sharedLib('books')(_)

books_.getImage = (entityUri, data)->
  _.preq.get app.API.entities.getImages(entityUri, data)
  .then _.property('images')

books_.getIsbnEntities = (isbns)->
  isbns = isbns.map books_.normalizeIsbn
  _.preq.get app.API.entities.isbns(isbns)
  .catch _.Error('getIsbnEntities err')

module.exports = books_