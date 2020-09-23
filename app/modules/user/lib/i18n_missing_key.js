missingKeys = []
disabled = false

module.exports = (key)->
  if disabled then return
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
    .catch (err)->
      if err.statusCode isnt 404 then throw err
      _.warn 'i18n missing key service is disabled'
      disabled = true
    .catch _.Error('i18n:missing keys failed to be added')

lazyMissingKey = _.debounce sendMissingKeys, 500
