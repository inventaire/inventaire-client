module.exports = (userId, uris)->
  if uris.length is 0 then return Promise.resolve {}

  # Split in batches for cases where there might be too many uris
  # to put in a URL querystring without risking to reach URL character limit
  # Known case: when /add/import gets to import very large collections
  # The alternative would be to convert the endpoint to a POST verb to pass those uris in a body
  urisBatches = _.chunk _.uniq(uris).sort(), 50

  responses = []
  counts = {}
  getBatchesSequentially = ->
    nextBatch = urisBatches.pop()
    unless nextBatch? then return counts
    getEntityItemsCountBatch userId, nextBatch
    .then (res)-> countEntitiesItems counts, res
    .then getBatchesSequentially

  getBatchesSequentially()

getEntityItemsCountBatch = (userId, uris)->
  _.preq.get app.API.items.byUserAndEntities(userId, uris)

countEntitiesItems = (counts, res)->
  for item in res.items
    uri = item.entity
    counts[uri] ?= 0
    counts[uri]++
  return
