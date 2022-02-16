import log_ from '#lib/loggers'
import Transactions from '#modules/transactions/collections/transactions'
import initHelpers from './helpers'
import fetchData from '#lib/data/fetch'
let lastTransactionId = null

export default {
  initialize () {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'transactions(/)': 'showFirstTransaction',
        'transactions/:id(/)': 'showTransaction'
      }
    })

    new Router({ controller: API })

    app.vent.on('transaction:select', updateTransactionRoute)

    app.commands.setHandlers({
      'show:item:request': API.showItemRequestModal,
      'show:transactions': API.showFirstTransaction,
      'show:transaction': API.showTransaction
    })

    app.reqres.setHandlers({
      'last:transaction:id' () { return lastTransactionId },
      'transactions:unread:count': unreadCount
    })

    app.vent.on('transaction:select', API.updateLastTransactionId)

    fetchData({
      name: 'transactions',
      Collection: Transactions,
      condition: app.user.loggedIn
    })
    .then(app.vent.Trigger('transactions:unread:changes'))
    .catch(log_.Error('transaction init err'))

    initHelpers()
  }
}

const API = {
  async showFirstTransaction () {
    if (app.request('require:loggedIn', 'transactions')) {
      await app.request('wait:for', 'transactions')
      await showTransactionsLayout()
      const firstTransaction = findFirstTransaction()
      if (firstTransaction != null) {
        lastTransactionId = firstTransaction.id
        // replacing the url to avoid being unable to hit 'previous'
        // as previous would be '/transactions' which would redirect again
        // to the first transaction
        const nonExplicitSelection = true
        app.vent.trigger('transaction:select', firstTransaction, nonExplicitSelection)
      } else {
        app.vent.trigger('transactions:welcome')
      }
    }
  },

  async showTransaction (id) {
    if (app.request('require:loggedIn', `transactions/${id}`)) {
      lastTransactionId = id
      // Wait for the transaction layout to let it the time to initialize event listers,
      // especially 'transaction:select'
      await showTransactionsLayout()

      await app.request('wait:for', 'transactions')
      triggerTransactionSelect(id)
    }
  },

  async showItemRequestModal (model) {
    if (app.request('require:loggedIn', model.get('pathname'))) {
      const { default: RequestItemModal } = await import('./views/request_item_modal')
      app.layout.showChildView('modal', new RequestItemModal({ model }))
    }
  },

  updateLastTransactionId (transaction) { lastTransactionId = transaction.id }
}

const showTransactionsLayout = async () => {
  const { default: TransactionsLayout } = await import('./views/transactions_layout')
  app.layout.showChildView('main', new TransactionsLayout())
}

const triggerTransactionSelect = function (id) {
  const pathname = `/transactions/${id}`
  const transaction = app.request('get:transaction:byId', id)
  if (transaction != null) {
    app.vent.trigger('transaction:select', transaction)
  } else {
    app.execute('show:error:missing', { pathname })
  }
}

const updateTransactionRoute = function (transaction) {
  transaction.beforeShow()
  app.navigateFromModel(transaction)
}

const findFirstTransaction = function () {
  let firstTransac = null
  const transacs = _.clone(app.transactions.models)
  while ((transacs.length > 0) && (firstTransac == null)) {
    const candidate = transacs.shift()
    if (!candidate.archived) firstTransac = candidate
  }

  return firstTransac
}

const unreadCount = function () {
  const transac = app.transactions?.models
  if (transac?.length <= 0) return 0

  return transac
  .map(_.property('unreadUpdate'))
  .reduce((a, b) => _.isNumber(b) ? a + b : a)
}
