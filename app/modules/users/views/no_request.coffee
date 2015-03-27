module.exports = NoRequest = Backbone.Marionette.ItemView.extend
  tagName: 'li'
  className: 'notification'
  template: require './templates/no_request'