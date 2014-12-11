ValidationButtons = require 'modules/general/views/validation_buttons'
ImageHandler = require 'lib/image_handler'

module.exports = class Other extends Backbone.Marionette.ItemView
  template: require './templates/other'
  onShow: ->
    app.layout.entities.search.results1.empty()
    app.layout.entities.search.validation.show new ValidationButtons

    ImageHandler.initialize()

  serializeData: ->
    listings: app.user.listings
