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
        'menu(/)': 'showProfileSettings'
      }
    })

    new Router({ controller: API })

    setHandlers()
  },
}

const API = {
  showProfileSettings () { showSettings('profile') },
  showAccountSettings () { showSettings('account') },
  showDisplaySettings () { showSettings('display') },
  showNotificationsSettings () { showSettings('notifications') },
  showDataSettings () { showSettings('data') }
}

const showSettings = async section => {
  if (app.request('require:loggedIn', `settings/${section}`)) {
    const { default: SettingsLayout } = await import('./components/settings_layout.svelte')
    return app.layout.getRegion('main').showSvelteComponent(SettingsLayout, {
      props: {
        section
      }
    })
  }
}

const setHandlers = () => app.commands.setHandlers({
  'show:settings': API.showProfileSettings,
  'show:settings:profile': API.showProfileSettings,
  'show:settings:account': API.showAccountSettings,
  'show:settings:display': API.showDisplaySettings,
  'show:settings:notifications': API.showNotificationsSettings,
  'show:settings:data': API.showDataSettings
})
