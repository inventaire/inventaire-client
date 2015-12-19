breq = require 'bluereq'
_ = require 'lodash'
writeSitemap = require './write_sitemap'
Promise = require 'bluebird'
{ folder, wdq, autolists } = require './config'


module.exports = ->
  promises = []
  for name, tupple of autolists
    promises.push generateFilesFromWdqItems name, tupple

  return Promise.all promises

generateFilesFromWdqItems = (name, tupple)->
  [ P, Q ] = tupple
  url = wdq P, Q
  console.log 'wdq url'.blue, url
  breq.get url
  .then _.property('body.items')
  .then getParts.bind(null, name)
  .map generateFile

getParts = (name, items)->
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

  console.log "got #{index} parts".green
  return parts

generateFile = (part)->
  { name, items, index } = part
  path = getFilePath name, index
  return writeSitemap path, wrapUrls(items.map(buildUrlNode))

wrapUrls = require './wrap_urls'

buildUrlNode = (id)->
  "<url><loc>https://inventaire.io/entity/wd:Q#{id}</loc></url>"

getFilePath = (name, index)-> "#{folder}/#{name}-#{index}.xml"
