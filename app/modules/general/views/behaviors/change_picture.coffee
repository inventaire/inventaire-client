module.exports = Marionette.ItemView.extend
  template: require './templates/change_picture'
  serializeData: -> @model.serializeData()
