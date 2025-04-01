import { canGoBack } from '#app/app'
import { commands } from '#app/radio'
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
    commands.execute('show:home')
  }
}

export function addNext () {
  // Supporting legacy add modes, ex: scan:embedded
  const addMode = getLastAddMode() || ''
  if (addMode.startsWith('scan')) {
    commands.execute('show:scanner:embedded')
  } else {
    commands.execute('show:add:layout', addMode)
  }
}
