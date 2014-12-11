EditUser = require 'modules/user/views/edit_user'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    ProfileRouter = Marionette.AppRouter.extend
      appRoutes:
        'profile/edit(/)': 'showEditUser'

    app.addInitializer ->
      new ProfileRouter
        controller: API

    app.commands.setHandlers
      'show:user:edit': ->
        app.layout.main.show new EditUser {model: app.user}
        app.navigate 'profile/edit'

API =
  showEditUser: -> app.execute 'show:user:edit'