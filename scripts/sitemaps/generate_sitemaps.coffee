breq = require 'bluereq'
_ = require 'lodash'
writeSitemap = require './write_sitemap'
{ folder } = require './config'
{ green, blue } = require 'chalk'
wdk = require 'wikidata-sdk'
queries = require './queries'

module.exports = -> Promise.all Object.keys(queries).map(generateFilesFromQuery)

generateFilesFromQuery = (name)->
  console.log green("#{name} query"), queries[name]
  breq.get queries[name]
  .get 'body'
  .then wdk.simplifySparqlResults
  .then getParts(name)
  .map generateFile

getParts = (name)-> (items)->
  parts = []
  index = 0

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
