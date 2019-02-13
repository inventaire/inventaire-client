#!/usr/bin/env coffee

CONFIG = require 'config'
__ = CONFIG.universalPath

# Avoid to use server-side modules, as it makes executing this script
# depend on the server side repository having run 'npm install'
# which might not be the case. Ex: client-only development environment
{ omit } = require 'lodash'
{ green, red } = require 'chalk'

fs = require 'fs'
{ promisify } = require 'util'
readFile = promisify fs.readFile
writeFile = promisify fs.writeFile

linkify = __.require 'client', 'app/lib/handlebars_helpers/linkify'
convertMarkdown = __.require('i18nSrc', 'lib/convert_markdown')(linkify)

{ Converter }  = require 'csvtojson'
converter = new Converter {}
convertFromString = promisify converter.fromString.bind(converter)

csvFile = __.path 'client', 'scripts/assets/mentions.csv'
jsonFile = __.path 'client', 'public/json/mentions.json'

cleanAttributes = (obj)->
  for k, v of obj
    if v is '' then delete obj[k]

  return obj

mentions = {}

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
      mentions[type] or= {}
      mentions[type][lang] or= []
      mentions[type][lang].push omit(el, ['type'])

    console.log 'mentions', mentions

    updatedFile = JSON.stringify mentions

    writeFile jsonFile, updatedFile
    .then -> console.log green('done!')
    .catch console.error.bind(console, red('build mentions'))
