{ Q } = require './wikidata_claims'

module.exports = (linkify, arg)->
  # ex: author = 'Ian Fleming'
  if _.isString arg then foramtString arg, linkify
  else
    { type, value, label } = arg
    switch type
      # ex: author = {type: 'string', value: 'Ian Fleming'}
      when 'string' then return foramtString value, linkify
      # ex: author = {type: 'wikidata_id', value: 'Q82104', label: 'Ian Fleming'}
      when 'wikidata_id' then return Q value, linkify, label
      else
        _.warn arg, 'unknown author data type'
        return

foramtString = (str, linkify)->
  if linkify then return linkifyAuthorString str
  else return str

linkifyAuthorString = (text)->
  "<a href='/search?q=#{text}' class='link searchAuthor'>#{text}</a>"
