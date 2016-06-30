# Fetching data in a standardized way:
# - attaching the created collection to window.app
# - firing resolveWaiter / rejectWaiter waiter based on the result

module.exports = (options)->
  { name, Collection, fetchCondition } = options
  app[name] = collection = new Collection

  fetchCondition ?= true

  if fetchCondition
    fetchPromise = _.preq.wrap collection.fetch(), { url: collection.url() }
  else
    fetchPromise = _.preq.resolved

  fetchPromise
  .then app.Execute('resolveWaiter', name)
  .catch app.Execute('rejectWaiter', name)

  return fetchPromise
