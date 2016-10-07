wd_ = require 'lib/wikimedia/wikidata'
requestBookCover = require './request_book_cover'

wdBooks_ = {}

wdBooks_.findAPictureByBookData = (bookModel)->
  if bookModel.get 'status.imageRequested' then return
  requestBookCover bookModel

wdBooks_.fetchAuthorsEntities = (bookModel)->
  authors = bookModel.get('claims.wdt:P50')
  if authors?.length > 0
    return app.request('get:entities:models', 'wd', authors)
  else
    label = bookModel.get('label')
    _.warn "no author found for #{label}"
    return _.preq.resolved

module.exports = wdBooks_
