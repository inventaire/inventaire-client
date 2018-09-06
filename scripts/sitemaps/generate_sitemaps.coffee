breq = require 'bluereq'
_ = require 'lodash'
writeSitemap = require './write_sitemap'
Promise = require '../lib/bluebird'
{ folder, autolists } = require './config'
{ green, blue } = require 'chalk'
wdk = require 'wikidata-sdk'

module.exports = -> Promise.all Object.keys(autolists).map(getPromise(autolists))

getPromise = (autolists)-> (name)->
  [ P, Q ] = autolists[name]
  return generateFilesFromClaim name, P, Q

generateFilesFromClaim = (name, P, Q)->
  url = wdk.getReverseClaims P, Q, { limit: 1000000 }
  breq.get url
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
    parts.push
      name: name
      items: part
      index: index

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
