{ Q } = require './wikidata_claims'

module.exports = (arg)->
  # ex: author = 'Ian Fleming'
  if _.isString arg then return linkifyAuthorString arg
  else
    { type, value, label } = arg
    switch type
      # ex: author = {type: 'string', value: 'Ian Fleming'}
      when 'string' then return linkifyAuthorString value
      # ex: author = {type: 'wikidata_id', value: 'Q82104', label: 'Ian Fleming'}
      when 'wikidata_id' then return Q value, true, label
      else
        _.warn arg, 'unknown author data type'
        return

linkifyAuthorString = (text)->
  "<a href='/search?q=#{text}' class='link searchAuthor'>#{text}</a>"
