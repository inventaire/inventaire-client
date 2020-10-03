import log_ from 'lib/loggers'
import preq from 'lib/preq'
// Fetching sequentially to lower stress on the different APIs
export default function (isbnsData) {
  const isbnsIndex = {}

  const commonRes = {
    entities: {},
    redirects: {},
    notFound: [],
    invalidIsbn: []
  }

  const uris = []

  isbnsData.forEach((isbnData, index) => {
    isbnData.index = index
    isbnsIndex[isbnData.isbn13] = isbnData
    // Invalid ISBNs won't have an isbn13 set, but there is always a normalized ISBN
    // so we re-index it
    isbnsIndex[isbnData.normalizedIsbn] = isbnData
    if (isbnData.isInvalid) {
      return commonRes.invalidIsbn.push(isbnData)
    } else {
      isbnData.uri = `isbn:${isbnData.isbn13}`
      return uris.push(isbnData.uri)
    }
  })

  if (uris.length === 0) { return Promise.resolve({ results: commonRes, isbnsIndex }) }

  const total = uris.length

  const updateProgression = function () {
    const done = total - uris.length
    return app.vent.trigger('progression:ISBNs', { done, total })
  }

  const fetchOneByOne = function () {
    const nextUri = uris.pop()
    if (nextUri == null) return

    return preq.get(app.API.entities.getByUris(nextUri, false, relatives))
    .then(res => {
      _.extend(commonRes.entities, res.entities)
      _.extend(commonRes.redirects, res.redirects)
      res.notFound?.forEach(pushNotFound(isbnsIndex, commonRes))
    })
    .tap(updateProgression)
    // Log errors without throwing to prevent crashing the whole chain
    .catch(log_.Error('fetchOneByOne err'))
    .then(fetchOneByOne)
  }

  updateProgression()

  return Promise.all([
    // Using 5 separate channels, fetching entities one by one, instead of
    // by batch, to avoid having one entity blocking a batch progression:
    // the hypothesis is that the request overhead should be smaller than
    // the time a new dataseed-based entity might take to be created
    fetchOneByOne(),
    fetchOneByOne(),
    fetchOneByOne(),
    fetchOneByOne(),
    fetchOneByOne()
  ])
  .then(() => ({
    results: commonRes,
    isbnsIndex
  }))
};

// Fetch the works associated to the editions, and those works authors
// to get access to the authors labels
const relatives = [ 'wdt:P629', 'wdt:P50' ]

const pushNotFound = (isbnsIndex, commonRes) => function (uri) {
  const isbn13 = uri.split(':')[1]
  const isbnData = isbnsIndex[isbn13]
  return commonRes.notFound.push(isbnData)
}
