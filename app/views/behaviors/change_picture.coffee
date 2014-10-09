module.exports = class ChangePicture extends Backbone.Marionette.ItemView
  template: require 'views/behaviors/templates/change_picture'
  serializeData: -> @model.serializeData()
