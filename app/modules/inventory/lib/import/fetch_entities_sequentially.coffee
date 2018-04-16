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

  if uris.length is 0 then return _.preq.resolve commonRes

  total = uris.length

  updateProgression = ->
    done = total - uris.length
    app.vent.trigger 'progression:ISBNs', { done, total }

  fetchOneByOne = ->
    nextUri = uris.pop()
    unless nextUri? then return

    _.preq.get app.API.entities.getByUris(nextUri, false, relatives)
    .then (res)->
      _.extend commonRes.entities, res.entities
      _.extend commonRes.redirects, res.redirects
      res.notFound?.forEach pushNotFound(isbnsIndex, commonRes)
    .tap updateProgression
    # Log errors without throwing to prevent crashing the whole chain
    .catch _.Error('fetchOneByOne err')
    .then fetchOneByOne

  updateProgression()

  Promise.all [
    # Using 5 separate channels, fetching entities one by one, instead of
    # by batch, to avoid having one entity blocking a batch progression:
    # the hypothesis is that the request overhead should be smaller than
    # the time a new dataseed-based entity might take to be created
    fetchOneByOne()
    fetchOneByOne()
    fetchOneByOne()
    fetchOneByOne()
    fetchOneByOne()
  ]
  .then -> { results: commonRes, isbnsIndex }

# Fetch the works associated to the editions, and those works authors
# to get access to the authors labels
relatives = [ 'wdt:P629', 'wdt:P50' ]

pushNotFound = (isbnsIndex, commonRes)-> (uri)->
  isbn = uri.split(':')[1]
  isbnData = isbnsIndex[isbn]
  commonRes.notFound.push isbnData
