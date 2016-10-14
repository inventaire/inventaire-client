module.exports = isbn_ = sharedLib('isbn')(_)

isbn_.getIsbnData = (isbn)-> _.preq.get app.API.data.isbn(isbn)
