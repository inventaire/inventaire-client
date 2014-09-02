ValidationButtons = require 'views/items/form/validation_buttons'

module.exports = class Other extends Backbone.Marionette.ItemView
  template: require 'views/items/form/templates/other'
  onShow: ->
    app.layout.entities.search.results1.empty()
    app.layout.entities.search.validation.show new ValidationButtons