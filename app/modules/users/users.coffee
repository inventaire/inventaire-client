UserContributions = require './views/user_contributions'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'u(sers)/:id/contributions(/)': 'showUserContributions'
        # Aliases
        'u(sers)/:id(/)': 'showUser'
        'u(sers)(/)': 'showSearchUsers'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    app.users = require('./users_collections')(app)

    require('./helpers')(app)
    require('./requests')(app, _)
    require('./invitations')(app, _)

    app.commands.setHandlers
      'show:user': app.Execute 'show:inventory:user'

    if app.user.loggedIn
      _.preq.get app.API.relations
      .then (relations)->
        app.relations = relations
        app.execute 'waiter:resolve', 'users'
      .catch _.Error('relations init err')
    else
      app.relations =
        friends: []
        userRequested: []
        otherRequested: []
        network: []

      app.execute 'waiter:resolve', 'users'

API =
  showUserContributions: (id)->
    path = "users/#{id}/contributions"
    if app.request 'require:loggedIn', path
      app.request 'get:user:model', id
      .then (user)->
        app.navigate path, { metadata: { title: 'contributions' } }
        if app.request 'require:admin:rights'
          app.layout.main.show new UserContributions { user }

  showUser: (id)-> app.execute 'show:inventory:user', id
  showSearchUsers: -> app.execute 'show:users:search'
