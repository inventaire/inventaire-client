wdk = require 'lib/wikidata-sdk'
isbn_ = require 'lib/isbn'

module.exports = (text)->
  text = text.trim()
  if _.isEntityUri text then return text
  if wdk.isWikidataItemId(text) then return 'wd:' + text
  if _.isInvEntityId(text) then return 'inv:' + text
  if isbn_.looksLikeAnIsbn(text) then return 'isbn:' + isbn_.normalizeIsbn(text)
  return
