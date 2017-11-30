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
    'click #signout': 'signout'

  showLink: (e)->
    unless _.isOpenedOutside e
      href = e.currentTarget.href.replace location.origin, ''
      { command, goBack } = hrefParams[href]
      app.execute command, e
      app.execute 'modal:close', goBack

  signout: ->
    app.execute 'modal:close'
    app.execute 'logout'

hrefParams =
  '/settings/profile': { command: 'show:settings:profile' }
  '/settings/notifications': { command: 'show:settings:notifications' }
  '/settings/labs': { command: 'show:settings:labs' }
  '/feedback': { command: 'show:feedback:menu', goBack: true }
  '/donate': { command: 'show:donate:menu', goBack: true }
