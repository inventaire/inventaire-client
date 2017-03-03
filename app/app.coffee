BindedPartialBuilder = require 'lib/binded_partial_builder'
updateMetadata = require 'lib/metadata/update'

App = Marionette.Application.extend
  initialize: ->
    require('modules/general/behaviors/base').initialize()
    @Execute = BindedPartialBuilder @, 'execute'
    @Request = BindedPartialBuilder @, 'request'
    @vent.Trigger = BindedPartialBuilder @vent, 'trigger'
    @once 'start', @onceStart.bind(@)

    navigateFromModel = (model, pathAttribute='pathname')->
      @navigate model.get(pathAttribute), { metadata: model.updateMetadata() }

    # Make it a binded function so that it can be reused elsewhere without
    # having to bind it again
    @navigateFromModel = navigateFromModel.bind @

  navigate: (route, options={})->
    unless _.isString route
      return _.error new Error("invalid route, can't navigate: #{route}")

    # Update metadata before testing if the route changed
    # so that a call from a router action would trigger a metadata update
    # but not affect the history (due to the early return hereafter)
    updateMetadata route, options.metadata
    # Easing code mutualization by firing app.navigate, even when the module
    # simply reacted to the requested URL
    if route is _.currentRoute() then return

    # a starting slash would be corrected by the Backbone.Router
    # but _.routeSection relies on the route not starting by a slash.
    # it can't just thrown an error as pathnames commonly require to start
    # by a slash to avoid being interpreted as relative pathnames
    route = route.replace /^\//, ''

    @vent.trigger 'route:change', _.routeSection(route), route
    route = route.replace /(\s|')/g, '_'
    route = @request 'querystring:keep', route
    Backbone.history.last or= []
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

  onceStart: ->
    routeFound = Backbone.history.start({pushState: true})

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
