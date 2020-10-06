import noNotificationTemplate from './templates/no_notification.hbs'

export default Marionette.ItemView.extend({
  tagName: 'li',
  className: 'notification',
  template: noNotificationTemplate
})
