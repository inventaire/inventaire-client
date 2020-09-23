wdk = require 'lib/wikidata-sdk'
isbn_ = require 'lib/isbn'

module.exports =
  getReverseClaims: (property, value, refresh, sort)->
    _.preq.get app.API.entities.reverseClaims(property, value, refresh, sort)
    .get 'uris'

  normalizeUri: (uri)->
    [ prefix, id ] = uri.split ':'
    if not id?
      if wdk.isWikidataItemId prefix then [ prefix, id ] = [ 'wd', prefix ]
      else if _.isInvEntityId prefix then [ prefix, id ] = [ 'inv', prefix ]
      else if isbn_.looksLikeAnIsbn prefix
        [ prefix, id ] = [ 'isbn', isbn_.normalizeIsbn(prefix) ]
    else
      if prefix is 'isbn' then id = isbn_.normalizeIsbn id

    if prefix? and id? then "#{prefix}:#{id}"
    else uri
