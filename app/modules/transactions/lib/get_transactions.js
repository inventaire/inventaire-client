import preq from '#lib/preq'
import { serializeTransaction } from '#transactions/lib/transactions'

async function fetchTransaction () {
  let { transactions } = await preq.get(app.API.transactions.base)
  return transactions
  .map(serializeTransaction)
  .sort(antiChronologically)
}

const antiChronologically = (a, b) => b.created - a.created

let waitForTransactions
export async function getTransactions () {
  waitForTransactions = waitForTransactions || await fetchTransaction()
  return waitForTransactions
}
