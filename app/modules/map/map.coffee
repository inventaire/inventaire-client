MapLayout = require './views/map_layout'
PositionPicker = require './views/position_picker'
map_ = require './lib/map'

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
        showMap { lat: lat, lng: lng, zoom: zoom }
        navigateMap lat, lng, zoom

      'show:position:picker:main:user': showMainUserPositionPicker
      'show:position:picker:group': showGroupPositionPicker

    app.reqres.setHandlers
      'prompt:position:picker': promptPositionPicker

showMap = (coordinates)->
  app.layout.main.show new MapLayout
    coordinates: coordinates

navigateMap = (lat, lng, zoom)->
  map_.updateRoute 'map', lat, lng, zoom

showPositionPicker = (options)->
  app.layout.modal.show new PositionPicker(options)

updatePosition = (model, updateReqres)->
  showPositionPicker
    model: model
    resolve: (newCoords, selector)->
      app.request updateReqres,
        attribute: 'position'
        value: newCoords
        selector: selector

showMainUserPositionPicker = -> updatePosition app.user, 'user:update'
showGroupPositionPicker = (group)-> updatePosition group, 'group:update:settings'

# returns a promise that should resolve with the selected coordinates
promptPositionPicker = ->
  new Promise (resolve, reject)->
    try showPositionPicker { resolve: resolve }
    catch err then reject err

routerAPI =
  showMap: (querystring)->
    coordinates = _.parseQuery querystring
    showMap coordinates
