module.exports = class NotificationLi extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'notification row'
  template: require './templates/notification_li'