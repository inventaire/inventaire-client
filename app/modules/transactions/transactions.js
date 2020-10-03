import log_ from 'lib/loggers'
import Transactions from 'modules/transactions/collections/transactions'
import TransactionsLayout from './views/transactions_layout'
import RequestItemModal from './views/request_item_modal'
import initHelpers from './helpers'
import fetchData from 'lib/data/fetch'
let lastTransactionId = null

export default {
  define (module, app, Backbone, Marionette, $, _) {
    const Router = Marionette.AppRouter.extend({
      appRoutes: {
        'transactions(/)': 'showFirstTransaction',
        'transactions/:id(/)': 'showTransaction'
      }
    })

    app.addInitializer(() => new Router({ controller: API }))
  },

  initialize () {
    this.listenTo(app.vent, 'transaction:select', updateTransactionRoute)

    app.commands.setHandlers({
      'show:item:request': API.showItemRequestModal,
      'show:transactions': API.showFirstTransaction,
      'show:transaction': API.showTransaction
    })

    app.reqres.setHandlers({
      'last:transaction:id' () { return lastTransactionId },
      'transactions:unread:count': unreadCount
    })

    this.listenTo(app.vent, 'transaction:select', API.updateLastTransactionId)

    fetchData({
      name: 'transactions',
      Collection: Transactions,
      condition: app.user.loggedIn
    })
    .then(app.vent.Trigger('transactions:unread:changes'))
    .catch(log_.Error('transaction init err'))

    return initHelpers()
  }
}

const API = {
  showFirstTransaction () {
    if (app.request('require:loggedIn', 'transactions')) {
      return app.request('wait:for', 'transactions')
      .then(showTransactionsLayout)
      .then(findFirstTransaction)
      .then(transac => {
        if (transac != null) {
          lastTransactionId = transac.id
          // replacing the url to avoid being unable to hit 'previous'
          // as previous would be '/transactions' which would redirect again
          // to the first transaction
          const nonExplicitSelection = true
          return app.vent.trigger('transaction:select', transac, nonExplicitSelection)
        } else {
          return app.vent.trigger('transactions:welcome')
        }
      })
      .catch(log_.Error('showFirstTransaction'))
    }
  },

  showTransaction (id) {
    if (app.request('require:loggedIn', `transactions/${id}`)) {
      lastTransactionId = id
      showTransactionsLayout()

      return app.request('wait:for', 'transactions')
      .then(triggerTransactionSelect.bind(null, id))
    }
  },

  showItemRequestModal (model) {
    if (app.request('require:loggedIn', model.get('pathname'))) {
      return app.layout.modal.show(new RequestItemModal({ model }))
    }
  },

  updateLastTransactionId (transac) {
    lastTransactionId = transac.id
  }
}

const showTransactionsLayout = () => app.layout.main.show(new TransactionsLayout())

const triggerTransactionSelect = function (id) {
  const transaction = app.request('get:transaction:byId', id)
  if (transaction != null) {
    return app.vent.trigger('transaction:select', transaction)
  } else { app.execute('show:error:missing') }
}

const updateTransactionRoute = function (transaction) {
  transaction.beforeShow()
  return app.navigateFromModel(transaction)
}

const findFirstTransaction = function () {
  let firstTransac = null
  const transacs = _.clone(app.transactions.models)
  while ((transacs.length > 0) && (firstTransac == null)) {
    const candidate = transacs.shift()
    if (!candidate.archived) { firstTransac = candidate }
  }

  return firstTransac
}

const unreadCount = function () {
  const transac = app.transactions?.models
  if (transac?.length <= 0) { return 0 }

  return transac
  .map(_.property('unreadUpdate'))
  .reduce((a, b) => { if (_.isNumber(b)) { return a + b } else { return a } })
}
