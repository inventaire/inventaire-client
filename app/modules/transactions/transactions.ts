import app from '#app/app'
import { addRoutes } from '#app/lib/router'
import { getRefreshedTransactions } from '#transactions/lib/get_transactions'
import initHelpers from './lib/helpers.ts'

export default {
  initialize () {
    addRoutes({
      '/transactions(/)': 'showTransactions',
      '/transactions/:id(/)': 'showTransaction',
    }, controller)

    app.commands.setHandlers({
      'show:transactions': controller.showTransactions,
      'show:transaction': controller.showTransaction,
    })

    initHelpers()
  },
}

const controller = {
  async showTransactions () {
    if (app.request('require:loggedIn', 'transactions')) {
      await showTransactionsLayout()
    }
  },

  async showTransaction (id: string) {
    if (app.request('require:loggedIn', `transactions/${id}`)) {
      await showTransactionsLayout(id)
    }
  },
} as const

async function showTransactionsLayout (selectedTransactionId?) {
  const transactions = await getRefreshedTransactions()
  const { default: TransactionsLayout } = await import('./components/transactions_layout.svelte')
  let selectedTransaction
  if (selectedTransactionId) {
    selectedTransaction = transactions.find(transaction => transaction._id === selectedTransactionId)
  }
  app.layout.showChildComponent('main', TransactionsLayout, {
    props: {
      transactions,
      selectedTransaction,
    },
  })
}
