# Fetching data in a standardized way:
# - use the passed collection or create one using the Collection class
#   attaching it to window.app
# - firing waiter:resolve / waiter:reject waiter based on the result

module.exports = (options)->
  { name, collection, Collection, condition, fetchOptions } = options

  unless collection?
    app[name] = collection = new Collection

  condition ?= true

  if condition
    fetchPromise = collection.fetch fetchOptions
  else
    fetchPromise = Promise.resolved

  fetchPromise
  .timeout 10000
  .then app.Execute('waiter:resolve', name)
  .catch app.Execute('waiter:reject', name)

  return fetchPromise
