#!/usr/bin/env coffee

[ resource, lang ] = process.argv.slice(2)

translatedLangs = [ 'de', 'es', 'fr', 'it', 'pl', 'sv', 'da']

projects =
  fullkey:
    name: 'inventaire_live'
    path: './public/i18n/src/fullkey/transifex/'
    en: './public/i18n/src/fullkey/en.json'
    enArchive: './public/i18n/src/fullkey/archive/en.json'
  shortkey:
    name: 'inventaire_live'
    path: './public/i18n/src/shortkey/transifex/'
    en: './public/i18n/src/shortkey/en.json'
    enArchive: './public/i18n/src/shortkey/archive/en.json'
  emails:
    name: 'inventaire'
    path: '../server/lib/emails/i18n/src/transifex/'
    en: '../server/lib/emails/i18n/src/en.json'
    enArchive: '../server/lib/emails/i18n/src/archive/en.json'

resources = Object.keys projects

breq = require 'bluereq'
Promise = require 'bluebird'
{ username, password } = require('config').transifex
json_ = require './lib/json'
_ = require 'lodash'

fetchTranslation = (resource, lang, enVersion)->
  unless lang in translatedLangs
    throw new Error "#{lang} isnt in the translated lang"

  project = projects[resource].name

  unless project?
    throw new Error "project couldnt be found for resource #{resource}"

  url = getUrl project, resource, lang
  breq.get url
  .then (res)->
    if res.statusCode is 404
      throw new Error "#{resource} - #{lang} : Not Found\n url: #{url}"

    console.log 'received'.green, lang

    pathBase = projects[resource].path

    json = JSON.parse res.body.content

    translations = {}
    for k, v of json
      # don't keep values that are just a copy of the English version
      # provided by Transifex as a placeholder
      unless (k is v or v is enVersion[k])
        if v? then translations[k] = v

    json_.write "#{pathBase}#{lang}.json", translations
    .then (res)->
      console.log 'saved'.green, resource, lang
      if res? then console.log res

  .catch (err)->
    console.error 'err', resource, lang, err.stack or err
    throw err


getUrl = (project, resource, lang)->
  "https://#{username}:#{password}@www.transifex.com/api/2/project/#{project}/resource/#{resource}/translation/#{lang}"

getEnVersion = (resource)->
  Promise.all [
      json_.read projects[resource].en
      json_.read projects[resource].enArchive
  ]
  .spread (current, archive={})-> _.extend {}, archive, current

for resource in resources
  getEnVersion resource
  .then (enVersion)->
    for lang in translatedLangs
      fetchTranslation resource, lang, enVersion
