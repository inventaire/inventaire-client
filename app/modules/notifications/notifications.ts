import app from '#app/app'
import { appLayout } from '#app/init_app_layout'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import { I18n } from '#user/lib/i18n'
import { getNotificationsData } from './lib/notifications'

let waitForNotifications

export default {
  initialize () {
    addRoutes({
      '/notifications(/)': 'showNotifications',
    }, controller)

    commands.setHandlers({
      'show:notifications': controller.showNotifications,
    })

    waitForNotifications = getNotificationsData()
  },
}

const controller = {
  async showNotifications () {
    if (reqres.request('require:loggedIn', 'notifications')) {
      commands.execute('show:loader')
      const [ { default: NotificationsLayout } ] = await Promise.all([
        import('./components/notifications_layout.svelte'),
        waitForNotifications,
      ])
      appLayout.showChildComponent('main', NotificationsLayout, {
        props: {},
      })
      app.navigate('notifications', { metadata: { title: I18n('notifications') } })
    }
  },
} as const
