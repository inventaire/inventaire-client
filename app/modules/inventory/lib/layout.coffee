# the layout mode is persisted to the localStorage
# to keep its state per-device

defaultLayout = 'cascade'

module.exports = (app)->
  layout = localStorage.getItem('layout') or defaultLayout

  setLayout = (newLayout)->
    layout = newLayout
    localStorage.setItem 'layout', layout

  app.reqres.setHandlers
    'inventory:layout': -> layout

  app.vent.on 'inventory:layout:change', setLayout
