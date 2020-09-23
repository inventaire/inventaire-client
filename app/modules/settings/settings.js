import SettingsLayout from './views/settings'
import screen_ from 'lib/screen'

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

    return app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () { return setHandlers() }
}

var API = {
  showProfileSettings () { return showSettings('profile') },
  showAccountSettings () { return showSettings('account') },
  showNotificationsSettings () { return showSettings('notifications') },
  showDataSettings () { return showSettings('data') }
}

var showSettings = function (tab) {
  if (app.request('require:loggedIn', `settings/${tab}`)) {
    return app.layout.main.show(new SettingsLayout({ model: app.user, tab }))
  }
}

var setHandlers = () => app.commands.setHandlers({
  'show:settings': API.showProfileSettings,
  'show:settings:profile': API.showProfileSettings,
  'show:settings:account': API.showAccountSettings,
  'show:settings:notifications': API.showNotificationsSettings,
  'show:settings:data': API.showDataSettings
})
