import log_ from '#lib/loggers'

export default function (transaction, state) {
  log_.info(arguments, 'applySideEffects')
  const { item } = transaction
  if (item) sideEffects[state](transaction, item)
  else log_.warn({ transaction, item }, "item not found: can't apply side-effect")
}

const setItemBusyness = (bool, transaction, item) => item.set('busy', bool)

const oneWay = {
  giving: true,
  lending: false,
  selling: true
}

const changeOwnerIfOneWay = function (transaction, item) {
  const transactionMode = transaction.get('transaction')
  const isOneWay = oneWay[transactionMode]
  if (isOneWay == null) {
    throw new Error(`invalid transaction mode: ${transactionMode}`)
  }

  if (isOneWay) {
    // Roughtly update the item to reflect the inventory change.
    // Will be fully updated from server at next data refresh
    return item.set({
      owner: transaction.get('requester'),
      details: '',
      transaction: 'inventorying',
      listing: 'private'
    })
  }
}

// Keep in sync server/controllers/transactions/lib/side_effects

const setItemToBusy = _.partial(setItemBusyness, true)
const setItemToNotBusy = _.partial(setItemBusyness, false)

const sideEffects = {
  accepted: setItemToBusy,
  declined: _.noop,
  confirmed: changeOwnerIfOneWay,
  returned: setItemToNotBusy,
  cancelled: setItemToNotBusy
}
