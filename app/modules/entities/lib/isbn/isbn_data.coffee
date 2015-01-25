module.exports = (app, _, books, promises_)->
  remote =
    get: books.getIsbnEntities

  local = new app.LocalCache
    name: 'entities_isbn'
    remote: remote
    parseData: (data)->
      _.log data, 'isbn parseData'

  return isbnData =
    local: local
    remote: remote