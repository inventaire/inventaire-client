// the layout mode is persisted to the localStorage
// to keep its state per-device

const defaultLayout = 'cascade'

export default function (app) {
  let layout = localStorageProxy.getItem('layout') || defaultLayout

  const setLayout = function (newLayout) {
    layout = newLayout
    return localStorageProxy.setItem('layout', layout)
  }

  app.reqres.setHandlers({ 'inventory:layout' () { return layout } })

  return app.vent.on('inventory:layout:change', setLayout)
};
