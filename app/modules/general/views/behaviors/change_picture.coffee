module.exports = class ChangePicture extends Backbone.Marionette.ItemView
  template: require './templates/change_picture'
  serializeData: -> @model.serializeData()
