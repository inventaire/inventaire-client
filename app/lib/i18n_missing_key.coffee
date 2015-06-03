missingKeys = []

module.exports = (key)->
  missingKeys.push key
  lazyMissingKey()

sendMissingKeys = ->
  $.post '/log/i18n', {missingKeys: _.uniq(missingKeys)}, null, 'json'
  .then (res)->
    _.log missingKeys, 'i18n:missing added'
    missingKeys = []
  .fail (err)->
    _.log err, 'i18n:missing keys failed to be added'

lazyMissingKey = _.debounce sendMissingKeys, 500
