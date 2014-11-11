module.exports = class NoRequest extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'noRequest row'
  template: require './templates/no_request'