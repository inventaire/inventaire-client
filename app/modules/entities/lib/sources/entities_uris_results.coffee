SearchResult = require 'modules/entities/models/search_result'
wdIdPattern = /Q\d+/
invIdPattern = /[0-9a-f]{32}/

getEntityUri = (input)->
  # Match ids instead of URIs to be very tolerent on the possible inputs
  wdId = input.match(wdIdPattern)?[0]
  if wdId? then return "wd:#{wdId}"
  invId = input.match(invIdPattern)?[0]
  if invId? then return "inv:#{invId}"

getEntityId = (input)-> getEntityUri(input)?.split(':')[1]

module.exports =
  getEntityUri: getEntityUri
  prepareSearchResult: (model)->
    [ prefix, id ] = model.get('uri').split(':')
    data = model.pick [ 'uri', 'labels', 'aliases', 'descriptions' ]
    data.id = id
    searchResult = new SearchResult data
    searchResult.fieldMatch = customFieldMatch
    return searchResult

# Let a full URL like
# http://localhost:3006/entity/inv:1d622035ca5515d12800e23e7f00c3eb
# match
# 1d622035ca5515d12800e23e7f00c3eb
customFieldMatch = (filterRegex, rawInput)-> (field)->
  unless field? then return false
  entityId = getEntityId rawInput
  fieldContainsInput = field.match(filterRegex)?
  inputContainsEntityId = entityId? and rawInput.match(entityId)?
  return fieldContainsInput or inputContainsEntityId
