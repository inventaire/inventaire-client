import { readable } from 'svelte/store'
import transactionsApi from '#app/api/transactions'
import log_ from '#app/lib/loggers'
import preq from '#app/lib/preq'
import { vent } from '#app/radio'
import { serializeTransaction, type SerializedTransaction } from '#transactions/lib/transactions'
import { mainUser } from '#user/lib/main_user'

async function fetchTransaction () {
  if (mainUser) {
    const { transactions } = await preq.get(transactionsApi.base)
    return transactions
    .map(serializeTransaction)
    .sort(antiChronologicallyWithNotReadFirst) as SerializedTransaction[]
  } else {
    return []
  }
}

function antiChronologicallyWithNotReadFirst (a, b) {
  if (!a.mainUserRead && b.mainUserRead) return -1
  else if (a.mainUserRead && !b.mainUserRead) return 1
  else return b.updated - a.updated
}

let waitForTransactions
export async function getTransactions () {
  waitForTransactions ??= await fetchTransaction()
  return waitForTransactions as Promise<SerializedTransaction[]>
}

export async function getRefreshedTransactions () {
  waitForTransactions = await fetchTransaction()
  return waitForTransactions as Promise<SerializedTransaction[]>
}

export async function getUnreadTransactionsCount () {
  const transactions = await getTransactions()
  return transactions.filter(transaction => !transaction.mainUserRead).length
}

let setUnreadTransactionsCount
let transactionsCount = 0
const unreadTransactionsCountStore = readable(transactionsCount, set => {
  setUnreadTransactionsCount = set
  setUnreadTransactionsCount(transactionsCount)
})

async function updateUnreadTransactionsCount () {
  const unreadTransactionsCount = await getUnreadTransactionsCount()
  // setUnreadTransactionsCount is only defined after the store callback has been called,
  // once the first consumer subscribed
  if (setUnreadTransactionsCount) setUnreadTransactionsCount(unreadTransactionsCount)
  transactionsCount = unreadTransactionsCount
}

export function getUnreadTransactionsCountStore () {
  updateUnreadTransactionsCount().catch(log_.error)
  return unreadTransactionsCountStore
}

vent.on('transactions:unread:change', updateUnreadTransactionsCount)
