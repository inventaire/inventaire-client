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

<url><loc>https://inventaire.io/</loc></url>
<url><loc>https://inventaire.io/signup</loc></url>
<url><loc>https://inventaire.io/login</loc></url>
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
  res.body.items.forEach addEntity
.then writeSiteMap
