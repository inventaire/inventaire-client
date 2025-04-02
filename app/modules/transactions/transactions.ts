import { appLayout } from '#app/init_app_layout'
import { addRoutes } from '#app/lib/router'
import { commands, reqres } from '#app/radio'
import { getTransactions } from '#transactions/lib/get_transactions'
import initHelpers from './lib/helpers.ts'

export default {
  initialize () {
    addRoutes({
      '/transactions(/)': 'showTransactions',
      '/transactions/:id(/)': 'showTransaction',
    }, controller)

    commands.setHandlers({
      'show:transactions': controller.showTransactions,
      'show:transaction': controller.showTransaction,
    })

    initHelpers()
  },
}

const controller = {
  async showTransactions () {
    if (reqres.request('require:loggedIn', 'transactions')) {
      await showTransactionsLayout()
    }
  },

  async showTransaction (id: string) {
    if (reqres.request('require:loggedIn', `transactions/${id}`)) {
      await showTransactionsLayout(id)
    }
  },
} as const

async function showTransactionsLayout (selectedTransactionId?) {
  const transactions = await getTransactions()
  const { default: TransactionsLayout } = await import('./components/transactions_layout.svelte')
  let selectedTransaction
  if (selectedTransactionId) {
    selectedTransaction = transactions.find(transaction => transaction._id === selectedTransactionId)
  }
  appLayout.showChildComponent('main', TransactionsLayout, {
    props: {
      transactions,
      selectedTransaction,
    },
  })
}
