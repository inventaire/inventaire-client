# Fetching data in a standardized way:
# - use the passed collection or create one using the Collection class
#   attaching it to window.app
# - firing waiter:resolve / waiter:reject waiter based on the result

module.exports = (options)->
  { name, Collection, Model, condition, fetchOptions } = options

  if Collection?
    app[name] = new Collection
  else
    app[name] = new Model

  condition ?= true

  if condition
    fetchPromise = app[name].fetch fetchOptions
  else
    fetchPromise = Promise.resolve()

  fetchPromise
  .timeout 10000
  .then app.Execute('waiter:resolve', name)
  .catch app.Execute('waiter:reject', name)

  return fetchPromise
