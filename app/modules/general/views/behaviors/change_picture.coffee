module.exports = ChangePicture = Backbone.Marionette.ItemView.extend
  template: require './templates/change_picture'
  serializeData: -> @model.serializeData()
