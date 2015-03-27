module.exports = NoNotification = Backbone.Marionette.ItemView.extend
  tagName: 'li'
  className: 'notification'
  template: require './templates/no_notification'