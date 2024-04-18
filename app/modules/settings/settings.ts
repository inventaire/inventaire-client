import app from '#app/app'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'settings(/profile)(/)': 'showProfileSettings',
        'settings/account(/)': 'showAccountSettings',
        'settings/display(/)': 'showDisplaySettings',
        'settings/notifications(/)': 'showNotificationsSettings',
        'settings/data(/)': 'showDataSettings',
        // Legacy
        'settings/labs(/)': 'showDataSettings',
        'menu(/)': 'showProfileSettings',
      },
    })

    new Router({ controller })

    setHandlers()
  },
}

const controller = {
  showProfileSettings () { showSettings('profile') },
  showAccountSettings () { showSettings('account') },
  showDisplaySettings () { showSettings('display') },
  showNotificationsSettings () { showSettings('notifications') },
  showDataSettings () { showSettings('data') },
}

const showSettings = async section => {
  if (app.request('require:loggedIn', `settings/${section}`)) {
    const { default: SettingsLayout } = await import('./components/settings_layout.svelte')
    return app.layout.showChildComponent('main', SettingsLayout, {
      props: {
        section,
      },
    })
  }
}

const setHandlers = () => app.commands.setHandlers({
  'show:settings': controller.showProfileSettings,
  'show:settings:profile': controller.showProfileSettings,
  'show:settings:account': controller.showAccountSettings,
  'show:settings:display': controller.showDisplaySettings,
  'show:settings:notifications': controller.showNotificationsSettings,
  'show:settings:data': controller.showDataSettings,
})
