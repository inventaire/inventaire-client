{ looksLikeAnIsbn, normalizeIsbn } = require 'lib/isbn'

module.exports = Backbone.Collection.extend
  model: require '../models/candidate'

  setAllSelectedTo: (bool)-> @each setSelected(bool)

  getSelected: -> @filter isSelected

  selectionIsntEmpty: -> @any isSelected

  addNewCandidates: (newCandidates)->
    alreadyAddedIsbns = @pluck 'normalizedIsbn'
    remainingCandidates = newCandidates.filter isNewCandidate(alreadyAddedIsbns)
    if remainingCandidates.length is 0 then return Promise.resolve []
    addExistingEntityItemsCounts remainingCandidates
    .then @add.bind(@)

isSelected = (model)-> model.get('selected')

setSelected = (bool)-> (model)->
  if model.canBeSelected() then model.set 'selected', bool

isNewCandidate = (alreadyAddedIsbns)-> (candidateData)->
  unless candidateData.title? or candidateData.normalizedIsbn? then return false
  return candidateData.normalizedIsbn not in alreadyAddedIsbns

addExistingEntityItemsCounts = (candidates)->
  uris = _.compact candidates.map(getUri)
  app.request 'items:getEntitiesItemsCount', app.user.id, uris
  .then addCounts(candidates)

getUri = (candidate)->
  { isbn, normalizedIsbn } = candidate
  normalizedIsbn ?= normalizeIsbn isbn
  candidate.normalizedIsbn = normalizedIsbn
  if looksLikeAnIsbn normalizedIsbn
    candidate.uri = "isbn:#{normalizedIsbn}"
    return candidate.uri

addCounts = (candidates)-> (counts)->
  candidates.forEach (candidate)->
    { uri } = candidate
    unless uri? then return
    count = counts[uri]
    if count? then candidate.existingEntityItemsCount = count

  return candidates
