module.exports = Backbone.Collection.extend
  model: require '../models/candidate'

  setAllSelectedTo: (bool)->
    @each (model)->
      if model.canBeSelected() then model.set 'selected', bool

  getSelected: -> @filter modelIsSelected
  selectionIsntEmpty: -> @any modelIsSelected

modelIsSelected = (model)-> model.get('selected')
