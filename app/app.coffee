class App extends Backbone.Marionette.Application
  initialize: =>

    @vent = new Backbone.Wreqr.EventAggregator()

    @Behaviors = require('behaviors/base')
    @Behaviors.initialize()

    @vent.on 'title:change', (title)->
      _.log title, 'title:change'
      document.title = "#{title} - Inventaire"

    @title = (title)-> @vent.trigger 'title:change', title

    @navigate = (route, options)->
      route.logIt('route:navigate')
      route = route.replace(/(\s|')/g, '_')
      Backbone.history.last ||= []
      Backbone.history.last.unshift(route)
      Backbone.history.navigate(route, options)

    @goTo = (route, options)->
      route.logIt('route:goTo')
      options ||= new Object
      options.trigger = true
      Backbone.history.navigate(route, options)

    @navigateReplace = (route, options)->
      route.logIt('route:navigateReplace')
      options ||= new Object
      options.replace = true
      @navigate(route, options)

    @on "start", (options) =>
      _.log 'app:start'
      routeFound = Backbone.history.start({pushState: true})

      unless routeFound
        console.error('route: not found! check if route is defined before app.start()')
        _.log Backbone.history.handlers, 'route: handlers at start'

module.exports = new App()