import { API } from '#app/api/api'
import { serverReportError } from '#app/lib/error'
import preq from '#app/lib/preq'
import { getTransactions } from '#transactions/lib/get_transactions'
import { getActiveTransactionsByItemId, serializeTransaction } from '#transactions/lib/transactions'
import { mainUser } from '#user/lib/main_user'

let transactions
export default async function () {
  transactions = await getTransactions()
}

export async function postTransactionMessage ({ transaction, message }) {
  const messageData = {
    action: 'message',
    transaction: transaction._id,
    message,
  }
  await preq.post(API.transactions.base, messageData)
  Object.assign(messageData, {
    user: mainUser?._id,
    created: Date.now(),
  })
  transaction.messages = transaction.messages.concat([ messageData ])
  return transaction
}

export function hasOngoingTransactionsByItemIdSync (itemId) {
  // Ideally, we would await the transactions, but that wouldn't be a sync function anymore
  if (!transactions) {
    serverReportError('called before transactions were initialized', {}, 500)
    return false
  }
  return transactions.find(transaction => transaction.item === itemId && !transaction.archived) != null
}

export async function postTransactionRequest ({ itemId, message }) {
  try {
    const { transaction } = await preq.post(API.transactions.base, {
      action: 'request',
      item: itemId,
      message,
    })
    const serializedTransaction = serializeTransaction(transaction)
    transactions.unshift(serializedTransaction)
    return serializedTransaction
  } catch (err) {
    // This case should normally not be possible, as UI elements should not offer to request
    // an item already requested, but it might not have worked if hasOngoingTransactionsByItemIdSync was not ready
    if (err.message === 'user already made a request on this item') {
      const transactions = await getActiveTransactionsByItemId(itemId)
      if (transactions[0]) return serializeTransaction(transactions[0])
    }
    throw err
  }
}
