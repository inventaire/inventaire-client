WdData = require './lib/wikidata/wikidata_data'
IsbnData = require './lib/isbn/isbn_data'
InvData = require './lib/inv/inv_data'
wd_ = require 'lib/wikidata'
books_ = require 'lib/books'

module.exports = (app, _, promises_)->
  wdData = WdData app, _, wd_, promises_
  isbnData = IsbnData app, _, books_, promises_
  invData = InvData app, _

  data =
    wd: wdData
    isbn: isbnData
    inv: invData

  # different from window.dbs.reset as it resets only entities caches
  reset = ->
    domains = [wdData, isbnData, invData]
    promises = domains.map (domain)-> domain.local.reset()
    return Promise.all promises

  get = (prefix, ids, format, refresh)->
    types = ['string', 'array|string', 'string|undefined', 'boolean']
    _.types arguments, types, 2

    provider = data[prefix]
    unless provider?
      return _.error [prefix, id], 'not implemented prefix, cant getEntityModel'

    return provider.local.get ids, format, refresh

  return data =
    wd: wdData
    isbn: isbnData
    inv: invData
    get: get
    reset: reset
