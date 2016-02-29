module.exports = (transaction, state)->
  _.log arguments, 'applySideEffects'
  { item } = transaction
  sideEffects[state](transaction, item)
  return

setItemBusyness = (bool, transaction, item)-> item.set 'busy', bool

oneWay =
  giving: true
  lending: false
  selling: true

changeOwnerIfOneWay = (transaction, item)->
  transactionMode = transaction.get 'transaction'
  isOneWay = oneWay[transactionMode]
  unless isOneWay?
    throw new Error("invalid transaction mode: #{transactionMode}")

  if isOneWay
    # Roughtly update the item to reflect the inventory change.
    # Will be fully updated from server at next data refresh
    item.set
      owner: transaction.get('requester')
      details: ''
      transaction: 'inventorying'
      listing: 'private'

actions =
  setItemBusyness: setItemBusyness
  changeOwnerIfOneWay: changeOwnerIfOneWay

sideEffects = sharedLib('transaction_side_effects')(actions, _)
