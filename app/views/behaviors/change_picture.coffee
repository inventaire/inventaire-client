module.exports = class ChangePicture extends Backbone.Marionette.ItemView
  template: require 'views/behaviors/templates/change_picture'
  initialize: ->
    @listenTo @model, 'add:pictures', @render

  serializeData: -> @model.serializeData()
