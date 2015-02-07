module.exports = (app, _, books, promises_)->
  remote =
    get: books.getIsbnEntities

  local = new app.LocalCache
    name: 'entities_isbn'
    normalizeId: books.normalizeIsbn
    remote: remote
    parseData: (data)-> _.log data, 'data:isbn:parse'

  return isbnData =
    local: local
    remote: remote