module.exports =
  define: (module, app, Backbone, Marionette, $, _)->

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
