Session = require 'modules/general/models/session'
BindedPartialBuilder = require 'lib/binded_partial_builder'

App = Marionette.Application.extend
  initialize: ->

    @session = new Session

    @Behaviors = require('modules/general/behaviors/base')
    @Behaviors.initialize()

    # TODO: replace by direct calls to 'metadata:update:title'
    @docTitle = (docTitle, noCompletion)->
      @execute 'metadata:update:title', docTitle, noCompletion

    @navigate = (route, options)->
      unless _.isString route
        return _.error route, "invalid route: can't navigate"

      # a starting slash would be corrected by the Backbone.Router
      # but _.routeSection relies on the route not starting by a slash.
      # it can't just thrown an error as pathnames commonly require to start
      # by a slash to avoid being interpreted as relative pathnames
      route = route.replace /^\//, ''

      # _.log route, 'route:change'
      @vent.trigger 'route:change', _.routeSection(route), route
      # record all routes visited for server-side statistics
      @session.record route
      route = route.replace /(\s|')/g, '_'
      route = @request 'route:querystring:keep', route
      Backbone.history.last or= []
      Backbone.history.last.unshift route
      Backbone.history.navigate route, options
      unless options?.preventScrollTop then scrollToPageTop()

    @goTo = (route, options)->
      # _.log route, 'route:goTo'
      options or= {}
      options.trigger = true
      Backbone.history.navigate(route, options)

    @navigateReplace = (route, options)->
      # _.log route, 'route:navigateReplace'
      options or= {}
      options.replace = true
      @navigate(route, options)

    @Execute = BindedPartialBuilder @, 'execute'
    @Request = BindedPartialBuilder @, 'request'

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
        app.vent.trigger 'route:change', _.routeSection(route), route

      unless routeFound
        console.error('route: not found! check
        if route is defined before app.start()')
        _.log Backbone.history.handlers, 'route: handlers at start'

module.exports = new App()

scrollToPageTop = -> window.scrollTo 0, 0
