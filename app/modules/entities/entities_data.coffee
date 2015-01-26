WdData = require './lib/wikidata/wikidata_data'
IsbnData = require './lib/isbn/isbn_data'
InvData = require './lib/inv/inv_data'

module.exports = (app, _, promises_)->
  wdData = WdData(app, _, app.lib.wikidata, promises_)
  isbnData = IsbnData(app, _, app.lib.books, promises_)
  invData = InvData(app, _)

  get = (prefix, ids, format, refresh)->
    types = ['string', 'array|string', 'string|undefined', 'boolean']
    _.types arguments, types, 2
    switch prefix
      when 'wd' then return wdData.local.get(ids, format, refresh)
      when 'isbn' then return isbnData.local.get(ids, format, refresh)
      when 'inv' then return invData.local.get(ids, format, refresh)
      else _.log [prefix, id], 'not implemented prefix, cant getEntityModel'


  return data =
    wd: wdData
    isbn: isbnData
    inv: invData
    get: get
