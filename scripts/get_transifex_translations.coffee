#!/usr/bin/env coffee

[ resource, lang ] = process.argv.slice(2)

translatedLangs = ['fr', 'de']

projects =
  fullkey:
    name: 'inventaire_live'
    path: './public/i18n/src/fullkey/transifex/'
  shortkey:
    name: 'inventaire_live'
    path: './public/i18n/src/shortkey/transifex/'
  emails:
    name: 'inventaire'
    path: '../server/lib/emails/i18n/src/transifex/'

resources = Object.keys projects

breq = require 'bluereq'
{ username, password } = require('config').transifex
json_ = require './lib/json'

fetchTranslation = (resource, lang)->
  unless lang in translatedLangs
    throw new Error "#{lang} isnt in the translated lang"

  project = projects[resource].name

  unless project?
    throw new Error "project couldnt be found for resource #{resource}"

  url = getUrl(project, resource, lang)
  breq.get url
  .then (res)->
    if res.statusCode is 404
      throw new Error "#{resource} - #{lang} : Not Found\n url: #{url}"

    console.log 'received'.green, lang

    pathBase = projects[resource].path

    json = JSON.parse res.body.content
    json_.write "#{pathBase}#{lang}.json", json
    .then (res)->
      console.log 'saved'.green, resource, lang
      if res? then console.log res

  .catch (err)->
    console.error 'err', resource, lang, err.stack or err


getUrl = (project, resource, lang)->
  "https://#{username}:#{password}@www.transifex.com/api/2/project/#{project}/resource/#{resource}/translation/#{lang}"

resources.forEach (resource)->
  translatedLangs.forEach fetchTranslation.bind(null, resource)
