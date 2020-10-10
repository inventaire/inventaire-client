import log_ from 'lib/loggers'
import { i18n } from 'modules/user/lib/i18n'
import preq from 'lib/preq'
import Notifications from './collections/notifications'
import NotificationsLayout from './views/notifications_layout'
const notifications = new Notifications()
let waitForNotifications

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'notifications(/)': 'showNotifications'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    app.commands.setHandlers({
      'show:notifications': API.showNotifications
    })

    app.reqres.setHandlers({
      'notifications:unread:count' () { return notifications.unreadCount() }
    })

    waitForNotifications = getNotificationsData()
  }
}

const API = {
  async showNotifications () {
    if (app.request('require:loggedIn', 'notifications')) {
      app.execute('show:loader')
      // Make sure that the notifications arrived before calling 'beforeShow'
      // as it will only trigger 'beforeShow' on the notifications models
      // presently in the collection
      await waitForNotifications
      await notifications.beforeShow()
      app.layout.main.show(new NotificationsLayout({ notifications }))
      app.navigate('notifications', {
        metadata: {
          title: i18n('notifications')
        }
      })
    }
  }
}

const getNotificationsData = async () => {
  if (!app.user.loggedIn) return

  const { notifications: userNotifications } = await preq.get(app.API.notifications)
  return notifications.addPerType(userNotifications)
}
