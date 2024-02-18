import initHelpers from './helpers.js'
import { getTransactions } from '#transactions/lib/get_transactions'

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'transactions(/)': 'showTransactions',
        'transactions/:id(/)': 'showTransaction'
      }
    })

    new Router({ controller: API })

    app.commands.setHandlers({
      'show:transactions': API.showTransactions,
      'show:transaction': API.showTransaction
    })

    // TODO: update and cleanup helpers
    initHelpers()
  }
}

const API = {
  async showTransactions () {
    if (app.request('require:loggedIn', 'transactions')) {
      await showTransactionsLayout()
    }
  },

  async showTransaction (id) {
    if (app.request('require:loggedIn', `transactions/${id}`)) {
      await showTransactionsLayout({ selectedTransactionId: id })
    }
  },
}

async function showTransactionsLayout (params = {}) {
  const { selectedTransactionId } = params
  const transactions = await getTransactions()
  const { default: TransactionsLayout } = await import('./components/transactions_layout.svelte')
  let selectedTransaction
  if (selectedTransactionId) {
    selectedTransaction = transactions.find(transaction => transaction._id === selectedTransactionId)
  }
  app.layout.showChildComponent('main', TransactionsLayout, {
    props: {
      transactions,
      selectedTransaction,
    }
  })
}
