import noNotificationTemplate from './templates/no_notification.hbs'

export default Marionette.View.extend({
  tagName: 'li',
  className: 'notification',
  template: noNotificationTemplate,
})
