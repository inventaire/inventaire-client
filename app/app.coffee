Session = require 'modules/general/models/session'

App = Marionette.Application.extend
  initialize: ->

    @session = new Session

    @vent = new Backbone.Wreqr.EventAggregator()

    @Behaviors = require('modules/general/behaviors/base')
    @Behaviors.initialize()

    @vent.on 'document:title:change', (title)->
      _.log title, 'document:title:change'
      document.title = "#{title} - Inventaire"

    @docTitle = (docTitle)-> @vent.trigger 'document:title:change', docTitle

    @navigate = (route, options)->
      unless route?
        return _.error route, "can't navigate to undefined route"

      route.logIt('route:navigate')
      @vent.trigger 'route:navigate', route
      # record all routes visited for server-side statistics
      @session.record route
      route = route.replace /(\s|')/g, '_'
      route = @request('route:querystring:keep', route)
      Backbone.history.last or= []
      Backbone.history.last.unshift route
      Backbone.history.navigate route, options
      scrollToPageTop()

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

      # records the first url found
      # as it wont go through navigate
      @session.record Backbone.history.fragment

      unless routeFound
        console.error('route: not found! check if route is defined before app.start()')
        _.log Backbone.history.handlers, 'route: handlers at start'

module.exports = new App()

scrollToPageTop = -> window.scrollTo 0, 0
