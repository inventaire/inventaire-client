import { localStorageProxy } from '#lib/local_storage'
// the layout mode is persisted to the localStorage
// to keep its state per-device

const defaultLayout = 'cascade'

export default function (app) {
  let layout = localStorageProxy.getItem('layout') || defaultLayout

  const setLayout = newLayout => {
    layout = newLayout
    localStorageProxy.setItem('layout', layout)
  }

  app.vent.on('inventory:layout:change', setLayout)
}
