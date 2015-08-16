missingKeys = []

module.exports = (key)->
  missingKeys.push key
  lazyMissingKey()

sendMissingKeys = ->
  _.preq.post '/log/i18n', {missingKeys: _.uniq(missingKeys)}
  .then (res)->
    _.log missingKeys, 'i18n:missing added'
    missingKeys = []
  .catch _.Error('i18n:missing keys failed to be added')

lazyMissingKey = _.debounce sendMissingKeys, 500
