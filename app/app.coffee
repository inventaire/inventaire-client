BindedPartialBuilder = require 'lib/binded_partial_builder'
updateMetadata = require 'lib/metadata/update'
initialUrlNavigateAlreadyCalled = false
error_ = require 'lib/error'
{ routeSection, currentRoute } = require 'lib/location'

App = Marionette.Application.extend
  initialize: ->
    Backbone.history.last = []
    require('modules/general/behaviors/base').initialize()
    @Execute = BindedPartialBuilder @, 'execute'
    @Request = BindedPartialBuilder @, 'request'
    @vent.Trigger = BindedPartialBuilder @vent, 'trigger'
    @once 'start', onceStart

    navigateFromModel = (model, pathAttribute = 'pathname', options = {})->
      # Polymorphism
      if _.isObject pathAttribute
        options = pathAttribute
        pathAttribute = 'pathname'

      options.metadata = model.updateMetadata()
      route = model.get pathAttribute
      if _.isNonEmptyString route
        @navigate route, options
      else
        error_.report "navigation model has no #{pathAttribute} attribute", model

    # Make it a binded function so that it can be reused elsewhere without
    # having to bind it again
    @navigateFromModel = navigateFromModel.bind @

  navigate: (route, options = {})->
    # Update metadata before testing if the route changed
    # so that a call from a router action would trigger a metadata update
    # but not affect the history (due to the early return hereafter)
    updateMetadata route, options.metadata
    # Easing code mutualization by firing app.navigate, even when the module
    # simply reacted to the requested URL
    if route is currentRoute()
      # Trigger a route event for the first URL, so that views listening
      # on the route:change event can update accordingly
      unless initialUrlNavigateAlreadyCalled
        @vent.trigger 'route:change', routeSection(route), route
        initialUrlNavigateAlreadyCalled = true
      return

    # a starting slash would be corrected by the Backbone.Router
    # but routeSection relies on the route not starting by a slash.
    # it can't just thrown an error as pathnames commonly require to start
    # by a slash to avoid being interpreted as relative pathnames
    route = route.replace /^\//, ''

    @vent.trigger 'route:change', routeSection(route), route
    route = @request 'querystring:keep', route
    Backbone.history.last.unshift route
    Backbone.history.navigate route, options
    unless options.preventScrollTop then scrollToPageTop()

  goTo: (route, options)->
    options or= {}
    options.trigger = true
    Backbone.history.navigate(route, options)

  navigateReplace: (route, options)->
    options or= {}
    options.replace = true
    @navigate route, options

onceStart = ->
  routeFound = Backbone.history.start { pushState: true }

  # Backbone.history 'route' event seem to be only triggerd
  # when 'previous' is hit. it isn't very clear why,
  # but it allows to notify functionalities depending on the route
  Backbone.history.on 'route', onPreviousRoute

onPreviousRoute = ->
  route = currentRoute()
  app.vent.trigger 'route:change', routeSection(route), route

module.exports = new App()

scrollToPageTop = -> window.scrollTo 0, 0
