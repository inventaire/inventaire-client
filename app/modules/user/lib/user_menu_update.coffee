AccountMenu = require 'modules/general/views/menu/account_menu'
NotLoggedMenu = require 'modules/general/views/menu/not_logged_menu'

module.exports = ->
  app.commands.setHandlers
    'show:user:menu:update': showMenu

  app.user.on 'change', showMenu

showMenu = ->
  if app.user.has 'email'
    app.layout?.accountMenu.show new AccountMenu {model: app.user}
  else
    app.layout?.accountMenu.show new NotLoggedMenu
