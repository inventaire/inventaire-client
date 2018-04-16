error_ = require 'lib/error'
importers = require './importers'

module.exports = (source, data)->
  { format, label, disableValidation } = importers[source]
  if disableValidation then return

  unless isValid[format](source, data)
    message = _.i18n 'data_mismatch', { source: label }
    # avoid attaching the whole file as context as it might be pretty heavy
    err = error_.new message, data[0..100]
    err.i18n = false
    throw err

isValid =
  csv: (source, data)->
    # Comparing the first 20 first characters
    # as those should be the header line and thus be constant
    first20Char = data[0...20]
    return first20Char is importers[source].first20Characters

  json: (source, data)->
    unless data[0] is '{' then return false
    # No headers line here, so we look for the presence of a specific key instead
    re = new RegExp importers[source].specificKey
    # Testing only an extract to avoid passing a super long doc to the regexp.
    # Make sure to choose a specificKey that would appear in this extract
    return re.test data[0..1000]

  all: -> true
