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
    getInstancesCountBatch userId, nextBatch
    .then (res)-> countInstances counts, res
    .then getBatchesSequentially

  getBatchesSequentially()

getInstancesCountBatch = (userId, uris)->
  _.preq.get app.API.items.byUserAndEntities(userId, uris)

countInstances = (counts, res)->
  for item in res.items
    uri = item.entity
    counts[uri] ?= 0
    counts[uri]++
  return
