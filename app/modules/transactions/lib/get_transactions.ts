import preq from '#lib/preq'
import { serializeTransaction } from '#transactions/lib/transactions'
import { readable } from 'svelte/store'
import transactionsApi from '#app/api/transactions'
import app from '#app/app'
import log_ from '#lib/loggers'

async function fetchTransaction () {
  await app.request('wait:for', 'user')
  if (app.user.loggedIn) {
    let { transactions } = await preq.get(transactionsApi.base)
    return transactions
    .map(serializeTransaction)
    .sort(antiChronologically)
  } else {
    return []
  }
}

const antiChronologically = (a, b) => b.created - a.created

let waitForTransactions
export async function getTransactions () {
  waitForTransactions = waitForTransactions || await fetchTransaction()
  return waitForTransactions
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

app.vent.on('transactions:unread:change', updateUnreadTransactionsCount)
