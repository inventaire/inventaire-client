missingKeys = []

module.exports = (key)->
  if key? and key not in missingKeys
    missingKeys.push key
    lazyMissingKey()

sendMissingKeys = ->
  if missingKeys.length > 0
    keysToSend = missingKeys
    # Keys added after this point will join the next batch
    missingKeys = []
    _.preq.post app.API.i18n, { missingKeys: keysToSend }
    .then (res)-> _.log keysToSend, 'i18n:missing added'
    .catch _.Error('i18n:missing keys failed to be added')

lazyMissingKey = _.debounce sendMissingKeys, 500
