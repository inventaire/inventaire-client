#!/usr/bin/env coffee

CONFIG = require 'config'
__ = CONFIG.universalPath
_ = __.require 'builders', 'utils'
bluebird = require 'bluebird'
fs = require 'fs'
readFile = bluebird.promisify fs.readFile
writeFile = bluebird.promisify fs.writeFile

linkify = __.require 'client', 'app/lib/handlebars_helpers/linkify'
convertMarkdown = __.require('i18nSrc', 'lib/convert_markdown')(linkify)

{ Converter }  = require 'csvtojson'
converter = new Converter {}
convertFromString = bluebird.promisify converter.fromString.bind(converter)

csvFile = __.path 'client', 'scripts/assets/mentions.csv'
jsonFile = __.path 'client', 'public/json/mentions.json'

mentions =
  tweets: {}
  articles: {}

cleanAttributes = (obj)->
  for k, v of obj
    if v is '' then delete obj[k]

  return obj


readFile csvFile, { encoding: 'utf-8' }
.then (file)->
  convertFromString file
  .then (data)->
    data
    .map cleanAttributes
    .forEach (el)->
      { type, lang } = el
      # convert type to plural form
      type += 's'
      el.text = convertMarkdown el.text
      mentions[type][lang] or= []
      mentions[type][lang].push _.omit(el, ['type', 'lang'])

    console.log 'mentions', mentions

    updatedFile = JSON.stringify mentions

    writeFile jsonFile, updatedFile
    .then -> _.success 'done!'
    .catch _.Error('build mentions')
