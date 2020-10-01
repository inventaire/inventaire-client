import Notifications from './collections/notifications'
import NotificationsLayout from './views/notifications_layout'
const notifications = new Notifications()
let waitForNotifications = null

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'notifications(/)': 'showNotifications'
      }
    })

    return app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.commands.setHandlers({ 'show:notifications': API.showNotifications })

    app.reqres.setHandlers({ 'notifications:unread:count' () { return notifications.unreadCount() } })

    return waitForNotifications = getNotificationsData()
  }
}

const API = {
  showNotifications () {
    if (app.request('require:loggedIn', 'notifications')) {
      app.execute('show:loader')
      // Make sure that the notifications arrived before calling 'beforeShow'
      // as it will only trigger 'beforeShow' on the notifications models
      // presently in the collection
      return waitForNotifications
      .then(() => notifications.beforeShow())
      .then(() => {
        app.layout.main.show(new NotificationsLayout({ notifications }))
        return app.navigate('notifications',
          { metadata: { title: _.i18n('notifications') } })
      })
    }
  }
}

const getNotificationsData = function () {
  if (!app.user.loggedIn) { return Promise.resolve() }

  return _.preq.get(app.API.notifications)
  .get('notifications')
  .then(notifications.addPerType.bind(notifications))
  .catch(_.ErrorRethrow('notifications init err'))
}
