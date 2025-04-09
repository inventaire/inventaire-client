import app from '#app/app'
import { getRefreshedTransactions } from '#transactions/lib/get_transactions'
import initHelpers from './lib/helpers.ts'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'transactions(/)': 'showTransactions',
        'transactions/:id(/)': 'showTransaction',
      },
    })

    new Router({ controller })

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

  async showTransaction (id) {
    if (app.request('require:loggedIn', `transactions/${id}`)) {
      await showTransactionsLayout(id)
    }
  },
}

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
