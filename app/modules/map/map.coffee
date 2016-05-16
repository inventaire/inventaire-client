PositionPicker = require './views/position_picker'
map_ = require './lib/map'

module.exports = ->
  app.commands.setHandlers
    'show:position:picker:main:user': showMainUserPositionPicker
    'show:position:picker:group': showGroupPositionPicker

  app.reqres.setHandlers
    'prompt:group:position:picker': promptGroupPositionPicker

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
  updatePosition app.user, 'user:update', 'user'

showGroupPositionPicker = (group, focusSelector)->
  updatePosition group, 'group:update:settings', 'group', focusSelector

# returns a promise that should resolve with the selected coordinates
promptGroupPositionPicker = ->
  new Promise (resolve, reject)->
    try showPositionPicker { resolve: resolve, type: 'group' }
    catch err then reject err
