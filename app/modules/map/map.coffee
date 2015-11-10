MapLayout = require './views/map_layout'
PositionPicker = require './views/position_picker'

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

      'show:position:picker': API.showPositionPicker

API =
  showMap: (coordinates)->
    app.layout.main.show new MapLayout
      coordinates: coordinates

  navigateMap: (lat, lng, zoom)->
    # keep only defined parameters in the route
    route = _.buildPath 'map', {lat: lat, lng: lng, zoom: zoom}
    app.navigate route

  showPositionPicker: ->
    app.layout.modal.show new PositionPicker

routerAPI =
  showMap: (querystring)->
    coordinates = _.parseQuery querystring
    API.showMap coordinates
