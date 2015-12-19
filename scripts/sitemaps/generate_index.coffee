_ = require 'lodash'
writeSitemap = require './write_sitemap'
fs = require 'fs'

{ publicPath, folder, main, index } = require './config'
list = [ main ]
exclude = [ main, index ]

module.exports = ->
  path = "#{folder}/#{index}"
  writeSitemap path, generate()

generate = ->
  wrapIndex getList().map(buildSitemapNode)

getList = ->
  fs.readdirSync folder
  .forEach (file)->
    unless file in exclude
      list.push file

  return list

buildSitemapNode = (filename)->
  url = "https://inventaire.io/#{publicPath}/#{filename}"
  "<sitemap><loc>#{url}</loc></sitemap>"

wrapIndex = (sitemapNodes)->
  text = sitemapNodes.join ''
  """
  <?xml version="1.0" encoding="UTF-8"?>
  <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  #{text}
  </sitemapindex>
  """
