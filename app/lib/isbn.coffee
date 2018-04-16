module.exports = isbn_ = sharedLib 'isbn'

isbn_.getIsbnData = (isbn)-> _.preq.get app.API.data.isbn(isbn)
