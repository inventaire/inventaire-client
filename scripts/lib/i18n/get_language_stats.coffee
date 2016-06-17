CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
fs = require 'graceful-fs'
{ Promise } = __.require 'lib', 'promises'
readFile = Promise.promisify fs.readFile
parse = JSON.parse.bind JSON

_.info 'emailKeys, shortKeys, fullKeys => total'

getKeysNumber = (path)->
  readFile path, {encoding: 'utf-8'}
  .then parse
  .then (obj)->
    _.values obj
    .filter _.isNonEmptyString
    .length
  .catch (err)->
    # return 0 if the file doesn't exist
    if err.code is 'ENOENT' then return 0
    else throw err

module.exports = (lang)->
  emailKeys = getKeysNumber __.path('i18nSrc', "#{lang}.json")
  shortKeys = getKeysNumber __.path('i18nClientSrc', "shortkey/#{lang}.json")
  fullKeys = getKeysNumber __.path('i18nClientSrc', "fullkey/#{lang}.json")

  Promise.all [ emailKeys, shortKeys, fullKeys ]
  .then (res)->
    total = res.sum()
    _.success "#{res} => #{total}", lang
    return total
