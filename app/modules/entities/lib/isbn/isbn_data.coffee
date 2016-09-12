localCache = require 'lib/data/local_cache'

module.exports = (app, _, books, promises_)->
  remote =
    get: books.getIsbnEntities

  local = localCache
    name: 'entities_isbn'
    normalizeId: books.normalizeIsbn
    remote: remote
    # parseData: _.Log('data:isbn:parse')

  return isbnData =
    local: local
    remote: remote