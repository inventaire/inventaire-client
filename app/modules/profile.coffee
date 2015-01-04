EditUser = require 'modules/user/views/edit_user'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    ProfileRouter = Marionette.AppRouter.extend
      appRoutes:
        'profile/edit(/)': 'showEditUser'
        'profile/edit/labs(/)': 'showLabsSettings'

    app.addInitializer ->
      new ProfileRouter
        controller: API

  initialize: -> setHandlers()

API =
  showEditUser: -> showEditUser()
  showLabsSettings: -> showEditUser 'labs'

showEditUser = (tab)->
  app.layout.main.show new EditUser {model: app.user, tab: tab}

setHandlers = ->
  app.commands.setHandlers
    'show:user:edit:profile': (tab)->
      API.showEditUser()
      app.navigate 'profile/edit'

    'show:user:edit:labs': (tab)->
      API.showLabsSettings()
      app.navigate 'profile/edit/labs'