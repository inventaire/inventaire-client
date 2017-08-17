CONFIG = require 'config'
__ = CONFIG.universalPath
fs = require 'graceful-fs'
Promise = require 'bluebird'
{ blue, green } = require 'chalk'
_ = require 'lodash'
readFile = Promise.promisify fs.readFile
parse = JSON.parse.bind JSON

console.log blue('emailKeys, shortKeys, fullKeys, wikidataKeys => total')

getKeysNumber = (path)->
  readFile path, { encoding: 'utf-8' }
  .then parse
  .then (obj)->
    _.values obj
    .filter (str)-> _.isString(str) and str.length > 0
    .length
  .catch (err)->
    # return 0 if the file doesn't exist
    if err.code is 'ENOENT' then return 0
    else throw err

module.exports = (lang)->
  emailKeys = getKeysNumber __.path('i18nSrc', getTranslatedFileName(null, lang))
  shortKeys = getKeysNumber __.path('i18nClientSrc', getTranslatedFileName('shortkey', lang))
  fullKeys = getKeysNumber __.path('i18nClientSrc', getTranslatedFileName('fullkey', lang))
  wikidataKeys = getKeysNumber __.path('i18nClientSrc', "wikidata/#{lang}.json")

  Promise.all [ emailKeys, shortKeys, fullKeys, wikidataKeys ]
  .then (res)->
    total = _.sum(res)
    console.log green(lang), "#{res} => #{total}"
    return total

getTranslatedFileName = (base, lang)->
  filename = if lang is 'en' then "#{lang}.json" else "transifex/#{lang}.json"
  if base then "#{base}/#{filename}" else filename
