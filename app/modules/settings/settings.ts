import { appLayout } from '#app/init_app_layout'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'

export default {
  initialize () {
    addRoutes({
      '/settings(/profile)(/)': 'showProfileSettings',
      '/settings/account(/)': 'showAccountSettings',
      '/settings/display(/)': 'showDisplaySettings',
      '/settings/notifications(/)': 'showNotificationsSettings',
      '/settings/data(/)': 'showDataSettings',
      // Legacy
      '/settings/labs(/)': 'showDataSettings',
      '/menu(/)': 'showProfileSettings',
    }, controller)

    setHandlers()
  },
}

const controller = {
  showProfileSettings () { showSettings('profile') },
  showAccountSettings () { showSettings('account') },
  showDisplaySettings () { showSettings('display') },
  showNotificationsSettings () { showSettings('notifications') },
  showDataSettings () { showSettings('data') },
} as const

const showSettings = async section => {
  if (reqres.request('require:loggedIn', `settings/${section}`)) {
    const { default: SettingsLayout } = await import('./components/settings_layout.svelte')
    appLayout.showChildComponent('main', SettingsLayout, {
      props: {
        section,
      },
    })
  }
}

const setHandlers = () => commands.setHandlers({
  'show:settings': controller.showProfileSettings,
  'show:settings:profile': controller.showProfileSettings,
  'show:settings:account': controller.showAccountSettings,
  'show:settings:display': controller.showDisplaySettings,
  'show:settings:notifications': controller.showNotificationsSettings,
  'show:settings:data': controller.showDataSettings,
})
