export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'settings(/profile)(/)': 'showProfileSettings',
        'settings/account(/)': 'showAccountSettings',
        'settings/notifications(/)': 'showNotificationsSettings',
        'settings/data(/)': 'showDataSettings',
        // Legacy
        'settings/labs(/)': 'showDataSettings',
        'menu(/)': 'showProfileSettings'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () { setHandlers() }
}

const API = {
  showProfileSettings () { showSettings('profile') },
  showAccountSettings () { showSettings('account') },
  showNotificationsSettings () { showSettings('notifications') },
  showDataSettings () { showSettings('data') }
}

const showSettings = async tab => {
  if (app.request('require:loggedIn', `settings/${tab}`)) {
    const { default: SettingsLayout } = await import('./views/settings')
    return app.layout.main.show(new SettingsLayout({ model: app.user, tab }))
  }
}

const setHandlers = () => app.commands.setHandlers({
  'show:settings': API.showProfileSettings,
  'show:settings:profile': API.showProfileSettings,
  'show:settings:account': API.showAccountSettings,
  'show:settings:notifications': API.showNotificationsSettings,
  'show:settings:data': API.showDataSettings
})
