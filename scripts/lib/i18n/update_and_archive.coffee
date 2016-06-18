Promise = require '../bluebird'
__ = require '../paths'
_ = require 'lodash'
json_  = require '../json'

module.exports =  (params)->
  { lang } = params

  Promise.all getUpdatePromises(params, lang)
  .then (res)->
    if res is false then console.log "#{lang} src empty: not updated".blue
    else console.log "#{lang} src updated!".blue
  .catch (err)->
    console.log "couldnt update #{lang} src files", err.stack
    throw err

getUpdatePromises = (params, lang)->
  promises = []
  for srcKey, paramsKey of srcKeyMap
    pathGetter = __.src[srcKey].bind(null, lang, true)
    promises.push writeIfNonEmpty(pathGetter, params[paramsKey])
  return promises

srcKeyMap =
  fullkey: 'updateFull'
  fullkeyArchive: 'archiveFull'
  shortkey: 'updateShort'
  shortkeyArchive: 'archiveShort'
  wikidata: 'updateWd'
  wikidataArchive: 'archiveWd'

writeIfNonEmpty = (pathGetter, strings)->
  if _.compact(_.values(strings)).length > 0
    return json_.write pathGetter(), strings
  else
    return Promise.resolve(false)
