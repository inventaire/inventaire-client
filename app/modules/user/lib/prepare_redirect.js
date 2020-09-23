{ buildPath } = require 'lib/location'
formAction = '/api/submit'

module.exports = (redirect)->
  redirect or= @options.redirect or app.request('querystring:get', 'redirect')

  unless _.isNonEmptyString redirect then return formAction

  if redirect[0] is '/' then redirect = redirect.slice(1)

  return buildPath formAction, { redirect }
