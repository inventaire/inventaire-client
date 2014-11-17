module.exports = class Error extends Backbone.Marionette.LayoutView
  id: 'error'
  template: require './templates/error'
  serializeData: -> return @options