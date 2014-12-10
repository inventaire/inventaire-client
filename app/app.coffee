class App extends Backbone.Marionette.Application
  initialize: =>

    @vent = new Backbone.Wreqr.EventAggregator()

    @Behaviors = require('modules/general/behaviors/base')
    @Behaviors.initialize()

    @vent.on 'document:title:change', (title)->
      _.log title, 'document:title:change'
      document.title = "#{title} - Inventaire"

    @docTitle = (docTitle)-> @vent.trigger 'document:title:change', docTitle

    @navigate = (route, options)->
      route.logIt('route:navigate')
      route = route.replace(/(\s|')/g, '_')
      Backbone.history.last or= []
      Backbone.history.last.unshift(route)
      Backbone.history.navigate(route, options)

    @goTo = (route, options)->
      route.logIt('route:goTo')
      options or= {}
      options.trigger = true
      Backbone.history.navigate(route, options)

    @navigateReplace = (route, options)->
      route.logIt('route:navigateReplace')
      options or= {}
      options.replace = true
      @navigate(route, options)

    @once 'start', (options) =>
      _.log 'app:start'
      routeFound = Backbone.history.start({pushState: true})

      unless routeFound
        console.error('route: not found! check if route is defined before app.start()')
        _.log Backbone.history.handlers, 'route: handlers at start'

module.exports = new App()