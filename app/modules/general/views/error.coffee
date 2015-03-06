module.exports = class Error extends Backbone.Marionette.LayoutView
  id: 'error'
  className: 'text-center'
  template: require './templates/error'
  serializeData: -> return @options