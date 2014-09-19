module.exports = class Error extends Backbone.Marionette.LayoutView
  id: 'error'
  template: require 'views/templates/error'
  serializeData: -> return @options