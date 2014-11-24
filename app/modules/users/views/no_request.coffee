module.exports = class NoRequest extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'notification'
  template: require './templates/no_request'