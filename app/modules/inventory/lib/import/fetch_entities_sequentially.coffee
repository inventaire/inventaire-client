# Fetching sequentially to lower stress on the different APIs
module.exports = (isbnsData)->
  isbnsIndex = {}

  commonRes =
    entities: {}
    redirects: {}
    notFound: []
    invalidIsbn: []

  uris = []

  isbnsData.forEach (isbnData, index)->
    isbnData.index = index
    isbnsIndex[isbnData.normalizedIsbn] = isbnData
    if isbnData.isInvalid
      commonRes.invalidIsbn.push isbnData
    else
      isbnData.uri = "isbn:#{isbnData.normalizedIsbn}"
      uris.push isbnData.uri

  fetchBatchesRecursively = ->
    batch = uris.splice 0, 9
    if batch.length is 0 then return _.preq.resolve commonRes

    _.preq.get app.API.entities.getByUris(batch, false, relatives)
    .then (res)->
      _.extend commonRes.entities, res.entities
      _.extend commonRes.redirects, res.redirects
      res.notFound?.forEach (uri)->
        isbn = uri.split(':')[1]
        isbnData = isbnsIndex[isbn]
        commonRes.notFound.push isbnData
    .then fetchBatchesRecursively

  fetchBatchesRecursively()
  .then -> { results: commonRes, isbnsIndex }

# Fetch the works associated to the editions, and those works authors
# to get access to the authors labels
relatives = [ 'wdt:P629', 'wdt:P50' ]
