MapLayout = require './views/map_layout'

module.exports =
  define: (Redirect, app, Backbone, Marionette, $, _) ->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'map': 'showMap'

    app.addInitializer ->
      new Router
        controller: routerAPI

  initialize: ->
    app.commands.setHandlers
      'show:map': (lat, lng, zoom)->
        API.showMap { lat: lat, lng: lng, zoom: zoom }
        API.navigateMap lat, lng, zoom

      'navigate:map': API.navigateMap

API =
  showMap: (coordinates)->
    app.layout.main.show new MapLayout
      coordinates: coordinates

  navigateMap: (lat, lng, zoom)->
    # keep only defined parameters in the route
    route = _.buildPath 'map', {lat: lat, lng: lng, zoom: zoom}
    app.navigate route

routerAPI =
  showMap: (querystring)->
    coordinates = _.parseQuery querystring
    API.showMap coordinates
