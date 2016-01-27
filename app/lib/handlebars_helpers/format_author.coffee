{ Q } = require './wikidata_claims'
{ SafeString, escapeExpression } = Handlebars

module.exports = (linkify, arg)->
  # ex: author = 'Ian Fleming'
  if _.isString arg then formatString arg, linkify
  else
    { type, value, label } = arg
    switch type
      # ex: author = {type: 'string', value: 'Ian Fleming'}
      when 'string' then return formatString value, linkify
      # ex: author = {type: 'wikidata_id', value: 'Q82104', label: 'Ian Fleming'}
      when 'wikidata_id' then return Q value, linkify, label
      else
        _.warn arg, 'unknown author data type'
        return

formatString = (str, linkify)->
  t = if linkify then linkifyAuthorString str else escapeExpression str
  return new SafeString t

linkifyAuthorString = (text)->
  str = escapeExpression text
  q = encodeURIComponent text
  return "<a href='/search?q=#{q}' class='link searchAuthor'>#{str}</a>"
