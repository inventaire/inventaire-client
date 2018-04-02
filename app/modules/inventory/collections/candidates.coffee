module.exports = Backbone.Collection.extend
  model: require '../models/candidate'

  setAllSelectedTo: (bool)-> @each setSelected(bool)

  getSelected: -> @filter isSelected

  selectionIsntEmpty: -> @any isSelected

isSelected = (model)-> model.get('selected')

setSelected = (bool)-> (model)->
  if model.canBeSelected() then model.set 'selected', bool
