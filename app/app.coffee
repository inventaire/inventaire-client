
class App extends Backbone.Marionette.Application
  initialize: =>

    @vent = new Backbone.Wreqr.EventAggregator()

    @Behaviors = require('behaviors/base')
    @Behaviors.initialize()

    @navigate = (route, options)->
      route.label('route:navigate')
      Backbone.history.navigate(route, options)

    @goTo = (route, options)->
      route.label('route:goTo')
      options ||= new Object
      options.trigger = true
      Backbone.history.navigate(route, options)

    @on "start", (options) =>
      _.log 'app:start'
      routeFound = Backbone.history.start({pushState: true})

      unless routeFound
        console.error('route: not found! check if route is defined before app.start()')
        _.log Backbone.history.handlers, 'route: handlers at start'

      if _.encodedURL()
        @navigate(_.getCurrentRoute().path.label('route:decodeURL'), {replace: true})

module.exports = new App()