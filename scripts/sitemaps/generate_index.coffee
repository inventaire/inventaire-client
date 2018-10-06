_ = require 'lodash'
writeSitemap = require './write_sitemap'
fs = require 'fs'

{ publicPath, folder, index } = require './config'
exclude = [ index ]

module.exports = ->
  path = "#{folder}/#{index}"
  writeSitemap path, generate()

generate = ->
  wrapIndex getList().map(buildSitemapNode)

getList = ->
  fs.readdirSync folder
  .filter (file)-> file not in exclude

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
