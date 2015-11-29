#!/usr/bin/env coffee

# generating a sitemap

breq = require 'bluereq'
fs = require 'fs'
wdk = require 'wikidata-sdk'
require 'colors'


begin = """
<?xml version="1.0" encoding="UTF-8"?>
<urlset
  xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
  http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">

<url>
  <loc>https://inventaire.io/</loc>
  <priority>1</priority>
</url>
<url>
  <loc>https://inventaire.io/signup</loc>
  <priority>0.9</priority>
</url>
<url>
  <loc>https://inventaire.io/login</loc>
  <priority>0.9</priority>
</url>
<url>
  <loc>https://inventaire.io/add</loc>
  <priority>0.9</priority>
</url>

"""
text = ''
end = "</urlset>\n"

addEntity = (id)-> text += "<url><loc>https://inventaire.io/entity/wd:Q#{id}</loc></url>\n"

writeSiteMap = ->
  console.log "writting sitemap".grey
  fs.writeFileSync './app/assets/sitemap.xml', (begin+text+end)
  console.log 'done!'.green

# entities with occupation=writter
url = wdk.getReverseClaims 'P106', 'Q36180'

console.log "fetching #{url}".grey
breq.get url
.then (res)->
  console.log "parsing response".grey
  { items } = res.body
  # google limits sitemaps to 50000 urls
  # several can be sent but its requires some rewritting here
  first49995 = items[0...49995]
  for item in first49995
    addEntity item
.then writeSiteMap
