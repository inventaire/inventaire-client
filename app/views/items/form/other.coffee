ValidationButtons = require 'views/items/form/validation_buttons'

module.exports = class Other extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/other'
  onShow: ->
    app.layout.item.creation.results1.empty()
    app.layout.item.creation.validation.show new ValidationButtons