module.exports = Backbone.Collection.extend
  model: require '../models/candidate'

  setAllSelectedTo: (bool)-> @each setSelected(bool)

  getSelected: -> @filter isSelected

  selectionIsntEmpty: -> @any isSelected

  addNewCandidates: (newCandidates)->
    alreadyAddedIsbns = @pluck 'normalizedIsbn'
    remainingCandidates = newCandidates.filter isNewCandidate(alreadyAddedIsbns)
    return @add remainingCandidates

isSelected = (model)-> model.get('selected')

setSelected = (bool)-> (model)->
  if model.canBeSelected() then model.set 'selected', bool

isNewCandidate = (alreadyAddedIsbns)-> (candidateData)->
  unless candidateData.title? or candidateData.normalizedIsbn? then return false
  return candidateData.normalizedIsbn not in alreadyAddedIsbns
