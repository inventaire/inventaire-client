urls = require 'lib/urls'

clickFn = (fn)-> (e)->
  unless _.isOpenedOutside e
    fn()
    app.execute 'modal:close'

module.exports = Marionette.ItemView.extend
  className: 'settings-menu'
  template: require './templates/settings_menu'
  serializeData: -> { urls }

  behaviors:
    PreventDefault: {}

  events:
    'click a': 'showLink'

  showLink: (e)->
    if e.currentTarget.id is 'signout' then return app.execute 'logout'

    unless _.isOpenedOutside e
      href = e.currentTarget.href.replace location.origin, ''
      { command, goBack } = hrefParams[href]
      app.execute command, e
      app.execute 'modal:close', goBack

hrefParams =
  '/welcome': { command: 'show:welcome' }
  '/settings/profile': { command: 'show:settings:profile' }
  '/settings/account': { command: 'show:settings:account' }
  '/settings/notifications': { command: 'show:settings:notifications' }
  '/settings/data': { command: 'show:settings:data' }
  '/feedback': { command: 'show:feedback:menu', goBack: true }
  '/donate': { command: 'show:donate:menu', goBack: true }
