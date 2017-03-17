{ root } = window.location
endpointBase = require('./endpoint')('feeds', true)
# Always using the absolute path so that links are treated as external links,
# thus getting target='_blank' attributes, and the associated click behaviors
# cf app/modules/general/lib/smart_prevent_default.coffee
endpoint = "#{root}#{endpointBase}"

module.exports = (key, id)->
  query = {}
  query[key] = id
  if app.user.loggedIn
    query.requester = app.user.id
    query.token = app.user.get 'readToken'

  return _.buildPath endpoint, query
