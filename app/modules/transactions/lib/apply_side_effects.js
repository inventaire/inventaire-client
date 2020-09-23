/* eslint-disable
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
export default function (transaction, state) {
  _.log(arguments, 'applySideEffects')
  const { item } = transaction
  sideEffects[state](transaction, item)
};

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

var sideEffects = {
  accepted: setItemToBusy,
  declined: _.noop,
  confirmed: changeOwnerIfOneWay,
  returned: setItemToNotBusy,
  cancelled: setItemToNotBusy
}
