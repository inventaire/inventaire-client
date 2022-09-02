export function guessInitialTransaction (transaction) {
  transaction = transaction || app.request('last:transaction:get')
  if (transaction === 'null') transaction = null
  app.execute('last:transaction:set', transaction)
  return transaction
}

export function cancel () {
  if (Backbone.history.last.length > 0) {
    window.history.back()
  } else {
    app.execute('show:home')
  }
}

export function addNext () {
  // Supporting legacy add modes, ex: scan:embedded
  const addMode = app.request('last:add:mode:get') || ''
  if (addMode.startsWith('scan')) {
    app.execute('show:scanner:embedded')
  } else {
    app.execute('show:add:layout', addMode)
  }
}
