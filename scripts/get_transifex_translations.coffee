#!/usr/bin/env coffee
CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
translatedLangs = require('./lib/i18n/langs').translated
require 'colors'

# For Live projects, Transifex doesn't pass the original key
# just a hash of the content and the source_string -_-
# cf http://docs.transifex.com/api/translation_strings/
# Thus, all resources where moved to non-hash keys

projects =
  fullkey:
    name: 'inventaire'
    path: './public/i18n/src/fullkey/transifex/'
    en: __.path 'i18nClientSrc', 'fullkey/en.json'
    enArchive: './public/i18n/src/fullkey/archive/en.json'
    hashKey: false
  shortkey:
    name: 'inventaire'
    path: './public/i18n/src/shortkey/transifex/'
    en: __.path 'i18nClientSrc', 'shortkey/en.json'
    enArchive: './public/i18n/src/shortkey/archive/en.json'
    hashKey: false
  emails:
    name: 'inventaire'
    path: '../server/lib/emails/i18n/src/transifex/'
    en: __.path 'i18nSrc', 'en.json'
    enArchive: '../server/lib/emails/i18n/src/archive/en.json'
    hashKey: false

resources = Object.keys projects

breq = require 'bluereq'
Promise = require './lib/bluebird'
{ username, password } = require('config').transifex
json_ = require './lib/json'
_ = require 'lodash'

fetchTranslation = (resource, lang, enVersion)->
  unless lang in translatedLangs
    throw new Error "#{lang} isnt in the translated lang"

  { name:project, hashKey, en:enPath } = projects[resource]

  if hashKey
    enObj = require enPath
    invertedEnObj = _.invert enObj
    getKey = (obj)-> invertedEnObj[obj.source_string]
  else
    # replacing '\\.\\.\\.' by '...'
    getKey = (obj)-> obj.key.replace /\\./g, '.'

  unless project?
    throw new Error "project couldnt be found for resource #{resource}"

  url = getUrl project, resource, lang
  # console.log('url', url)
  breq.get url
  .then (res)->
    # console.log 'received'.green, lang
    strings = res.body
    translations = {}
    # console.log('strings', typeof strings, Object.keys(strings))
    for strObj in strings
      key = getKey strObj
      { translation } = strObj
      val = if translation isnt '' then formatValue(translation) else null
      if key? then translations[key] = val
      else console.warn 'key not found: ignoring'.yellow, strObj

    pathBase = projects[resource].path
    json_.write "#{pathBase}#{lang}.json", translations
    .then (res)->
      console.log 'saved'.green, resource, lang
      if res? then console.log res

  .catch (err)->
    # if res.statusCode is 404
      # throw new Error "#{resource} - #{lang} : Not Found\n url: #{url}"
    console.error 'err', resource, lang, err.stack or err
    throw err


getUrl = (project, resource, lang)->
  "https://#{username}:#{password}@www.transifex.com/api/2/project/#{project}/resource/#{resource}/translation/#{lang}/strings"

getEnVersion = (resource)->
  Promise.all [
      json_.read projects[resource].en
      json_.read projects[resource].enArchive
  ]
  .spread (current, archive={})-> _.extend {}, archive, current

formatValue = (val)->
  # two backslash and a point
  return val.replace '\u005c\u005c.', '.'

resources.forEach (resource)->
  getEnVersion resource
  .then (enVersion)->
    for lang in translatedLangs
      fetchTranslation resource, lang, enVersion
