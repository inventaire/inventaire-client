import app from '#app/app'
import preq from '#app/lib/preq'
import { i18n } from '#user/lib/i18n'
import Notifications from './collections/notifications.ts'

const notifications = new Notifications()
let waitForNotifications

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'notifications(/)': 'showNotifications',
      },
    })

    new Router({ controller })

    app.commands.setHandlers({
      'show:notifications': controller.showNotifications,
    })

    app.reqres.setHandlers({
      'notifications:unread:count' () { return notifications.unreadCount() },
    })

    waitForNotifications = getNotificationsData()
  },
}

const controller = {
  async showNotifications () {
    if (app.request('require:loggedIn', 'notifications')) {
      app.execute('show:loader')
      const [ { default: NotificationsLayout } ] = await Promise.all([
        import('./views/notifications_layout.ts'),
        // Make sure that the notifications arrived before calling 'beforeShow'
        // as it will only trigger 'beforeShow' on the notifications models
        // presently in the collection
        waitForNotifications.then(notifications.beforeShow.bind(notifications)),
      ])
      app.layout.showChildView('main', new NotificationsLayout({ notifications }))
      app.navigate('notifications', {
        metadata: {
          title: i18n('notifications'),
        },
      })
    }
  },
}

const getNotificationsData = async () => {
  if (!app.user.loggedIn) return

  const { notifications: userNotifications } = await preq.get(app.API.notifications)
  return notifications.addPerType(userNotifications)
}
