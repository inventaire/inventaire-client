breq = require 'bluereq'
_ = require 'lodash'
writeSitemap = require './write_sitemap'
{ folder } = require './config'
{ green, blue } = require 'chalk'
wdk = require 'wikidata-sdk'
queries = require './queries'

module.exports = ->
  queriesNames = Object.keys queries

  # Generating sequentially to prevent overpassing Wikidata Query Service parallel request quota
  generateFilesSequentially = ->
    nextQueryName = queriesNames.shift()
    unless nextQueryName? then return console.log green("done")
    generateFilesFromQuery nextQueryName
    .then generateFilesSequentially

  return generateFilesSequentially()

generateFilesFromQuery = (name)->
  console.log green("#{name} query"), queries[name]
  breq.get
    url: queries[name]
    headers:
      'user-agent': 'inventaire-client (https://github.com/inventaire/inventaire-client)'
  .get 'body'
  .then (results)->
    try
      return wdk.simplifySparqlResults results
    catch err
      console.error 'failed to parse SPARQL results', results
      throw err
  .then getParts(name)
  .map generateFile

getParts = (name)-> (items)->
  parts = []
  index = 0

  items = _.uniq items

  while items.length > 0
    # override items
    [ part, items ] = [ items[0..49999], items[50000..-1] ]
    index += 1
    parts.push { name, items: part, index }

  console.log green("got #{index} parts")
  return parts

generateFile = (part)->
  { name, items, index } = part
  path = getFilePath name, index
  return writeSitemap path, wrapUrls(items.map(buildUrlNode))

wrapUrls = require './wrap_urls'

buildUrlNode = (id)->
  "<url><loc>https://inventaire.io/entity/wd:#{id}</loc></url>"

getFilePath = (name, index)-> "#{folder}/#{name}-#{index}.xml"
