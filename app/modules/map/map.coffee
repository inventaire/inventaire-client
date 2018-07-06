onScriptReady = require('./lib/config').init
{ get:getLeaflet } = require('lib/get_assets')('leaflet', onScriptReady)
PositionPicker = require './views/position_picker'

module.exports = ->
  app.commands.setHandlers
    'show:position:picker:main:user': showMainUserPositionPicker
    'show:position:picker:group': showGroupPositionPicker

  app.reqres.setHandlers
    'prompt:group:position:picker': promptGroupPositionPicker
    'map:before': getLeaflet

showPositionPicker = (options)->
  app.layout.modal.show new PositionPicker(options)

updatePosition = (model, updateReqres, type, focusSelector)->
  showPositionPicker
    model: model
    type: type
    focus: focusSelector
    resolve: (newCoords, selector)->
      app.request updateReqres,
        attribute: 'position'
        value: newCoords
        selector: selector
        # required by reqres updaters such as group:update:settings
        model: model

showMainUserPositionPicker = ->
  getLeaflet()
  .then -> updatePosition app.user, 'user:update', 'user'

showGroupPositionPicker = (group, focusSelector)->
  getLeaflet()
  .then -> updatePosition group, 'group:update:settings', 'group', focusSelector

# returns a promise that should resolve with the selected coordinates
promptGroupPositionPicker = ->
  getLeaflet()
  .then ->
    new Promise (resolve, reject)->
      try showPositionPicker { resolve, type: 'group' }
      catch err then reject err
