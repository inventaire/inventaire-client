module.exports = class NoNotification extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'notification'
  template: require './templates/no_notification'