import { findNextActions } from './transactions.js'
import * as infoPartials from './info_partials.js'

export const getNextActionsData = function (transaction) {
  const nextActions = findNextActions(transaction)
  if (nextActions == null) return
  let data = getActionsData()[nextActions]
  if (data == null) return
  data = addTransactionInfo(data, transaction)
  return grabOtherUsername(transaction, data)
}

const addTransactionInfo = function (data, transaction) {
  const { transaction: transactionName, item: itemId } = transaction
  return data.map(action => {
    action[transactionName] = true
    action.itemId = itemId
    const infoData = infoPartials[transactionName][action.text]
    if (infoData != null) Object.assign(action, infoData)
    return action
  })
}

const grabOtherUsername = function (transaction, actions) {
  const { username } = transaction.snapshot.other
  return actions.map(action => Object.assign({}, action, { username }))
}

const waiting = text => ({
  waiting: true,
  state: 'waiting',
  text
})

const getActionsData = () => ({
  'accept/decline':
    [
      { state: 'accepted', text: 'accept_request' },
      { state: 'declined', text: 'decline_request' }
    ],

  confirm: [ { state: 'confirmed', text: 'confirm_reception' } ],
  returned: [ { state: 'returned', text: 'confirm_returned' } ],
  'waiting:accepted': [ waiting('waiting_accepted') ],
  'waiting:confirmed': [ waiting('waiting_confirmation') ],
  'waiting:returned': [ waiting('waiting_return_confirmation') ]
})
