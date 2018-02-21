# Fetching sequentially to lower stress on the different APIs
module.exports = (isbnsData)->
  isbnsIndex = {}
  isbnsData.forEach (isbnData)->
    isbnData.rawUri = "isbn:#{isbnData.normalized}"
    isbnsIndex[isbnData.normalized] = isbnData

  uris = _.pluck isbnsData, 'rawUri'

  commonRes =
    entities: {}
    redirects: {}
    notFound: []

  fetchBatchesRecursively = ->
    batch = uris.splice 0, 9
    if batch.length is 0 then return

    _.preq.get app.API.entities.getByUris(batch, false, relatives)
    .then (res)->
      _.extend commonRes.entities, res.entities
      _.extend commonRes.redirects, res.redirects
      res.notFound?.forEach (notFoundData)->
        isbnData = isbnsIndex[notFoundData.isbn]
        commonRes.notFound.push isbnData
    .then fetchBatchesRecursively

  fetchBatchesRecursively()
  .then -> { results: commonRes, isbnsIndex }

# Fetch the works associated to the editions, and those works authors
# to get access to the authors labels
relatives = [ 'wdt:P629', 'wdt:P50', ]
