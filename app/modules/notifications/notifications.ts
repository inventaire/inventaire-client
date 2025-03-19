import app from '#app/app'
import { I18n } from '#user/lib/i18n'
import { getNotificationsData } from './lib/notifications'

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

    waitForNotifications = getNotificationsData()
  },
}

const controller = {
  async showNotifications () {
    if (app.request('require:loggedIn', 'notifications')) {
      app.execute('show:loader')
      const [ { default: NotificationsLayout } ] = await Promise.all([
        import('./components/notifications_layout.svelte'),
        waitForNotifications,
      ])
      app.layout.showChildComponent('main', NotificationsLayout, {
        props: {},
      })
      app.navigate('notifications', { metadata: { title: I18n('notifications') } })
    }
  },
}
