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
      app.execute hrefCommands[href], e
      app.execute 'modal:close'

  signout: ->
    app.execute 'modal:close'
    app.execute 'logout'

hrefCommands =
  '/settings/profile': 'show:settings:profile'
  '/settings/notifications': 'show:settings:notifications'
  '/settings/labs': 'show:settings:labs'
  '/feedback': 'show:feedback:menu'
  '/donate': 'show:donate:menu'
