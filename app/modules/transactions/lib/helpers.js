import preq from '#lib/preq'
import { getTransactions } from '#transactions/lib/get_transactions'
import error_ from '#lib/error'
import { serializeTransaction } from '#transactions/lib/transactions'

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
  await preq.post(app.API.transactions.base, messageData)
  Object.assign(messageData, {
    user: app.user.id,
    created: Date.now()
  })
  transaction.messages = transaction.messages.concat([ messageData ])
  return transaction
}

export function hasOngoingTransactionsByItemIdSync (itemId) {
  // Ideally, we would await the transactions, but that wouldn't be a sync function anymore
  if (!transactions) throw error_.new('called before transactions were initialized', 500)
  return transactions.find(transaction => transaction.item === itemId && !transaction.archived) != null
}

export async function postTransactionRequest ({ itemId, message }) {
  const { transaction } = await preq.post(app.API.transactions.base, {
    action: 'request',
    item: itemId,
    message,
  })
  const serializedTransaction = serializeTransaction(transaction)
  transactions.unshift(serializedTransaction)
  return serializedTransaction
}
