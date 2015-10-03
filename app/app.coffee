Session = require 'modules/general/models/session'

App = Marionette.Application.extend
  initialize: ->

    @session = new Session

    @vent = new Backbone.Wreqr.EventAggregator()

    @Behaviors = require('modules/general/behaviors/base')
    @Behaviors.initialize()

    @vent.on 'document:title:change', (title, noCompletion)->
      app.execute 'metadata:update:title', title, noCompletion
      app.execute 'track:page:view', title

    @docTitle = (docTitle, noCompletion)->
      @vent.trigger 'document:title:change', docTitle, noCompletion

    @navigate = (route, options)->
      unless _.isString route
        return _.error route, "invalid route: can't navigate"

      # a starting slash would be corrected by the Backbone.Router
      # but _.routeSection relies on the route not starting by a slash.
      # it can't just thrown an error as pathnames commonly require to start
      # by a slash to avoid being interpreted as relative pathnames
      route = route.replace /^\//, ''

      # route.logIt('route:navigate')
      @vent.trigger 'route:navigate', _.routeSection(route), route
      # record all routes visited for server-side statistics
      @session.record route
      route = route.replace /(\s|')/g, '_'
      route = @request 'route:querystring:keep', route
      Backbone.history.last or= []
      Backbone.history.last.unshift route
      Backbone.history.navigate route, options
      scrollToPageTop()

    @goTo = (route, options)->
      # route.logIt('route:goTo')
      options or= {}
      options.trigger = true
      Backbone.history.navigate(route, options)

    @navigateReplace = (route, options)->
      # route.logIt('route:navigateReplace')
      options or= {}
      options.replace = true
      @navigate(route, options)

    @once 'start', (options) =>
      # _.log 'app:start'
      routeFound = Backbone.history.start({pushState: true})

      # records the first url found
      # as it wont go through navigate
      @session.record Backbone.history.fragment

      # Backbone.history 'route' event seem to be only triggerd
      # when 'previous' is hit. it isn't very clear why,
      # but it allows to notify functionalities depending on the route
      Backbone.history.on 'route', ->
        route = _.currentRoute()
        app.vent.trigger 'route:navigate', _.routeSection(route), route

      unless routeFound
        console.error('route: not found! check
        if route is defined before app.start()')
        _.log Backbone.history.handlers, 'route: handlers at start'

module.exports = new App()

scrollToPageTop = -> window.scrollTo 0, 0
