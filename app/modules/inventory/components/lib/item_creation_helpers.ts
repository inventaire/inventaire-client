import app, { canGoBack } from '#app/app'
import { getLastAddMode, getLastTransaction, getLastVisbility } from '#inventory/lib/add_helpers'

export function guessInitialTransaction (transaction) {
  transaction = transaction || getLastTransaction()
  if (transaction === 'null') transaction = null
  return transaction || 'inventorying'
}

export function guessInitialVisibility (visibility) {
  visibility = visibility || getLastVisbility()
  if (visibility === 'null') visibility = []
  return visibility || []
}

export function cancel () {
  if (canGoBack()) {
    window.history.back()
  } else {
    app.execute('show:home')
  }
}

export function addNext () {
  // Supporting legacy add modes, ex: scan:embedded
  const addMode = getLastAddMode() || ''
  if (addMode.startsWith('scan')) {
    app.execute('show:scanner:embedded')
  } else {
    app.execute('show:add:layout', addMode)
  }
}
