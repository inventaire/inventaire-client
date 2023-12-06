import FilteredCollection from 'backbone-filtered-collection'
import preq from '#lib/preq'

export default function () {
  app.reqres.setHandlers({
    'transactions:add': API.addTransaction,
    'get:transaction:byId': API.getTransaction,
  })

  return app.request('wait:for', 'user').then(initLateHelpers)
}

const API = {
  addTransaction (transaction) { return app.transactions.add(transaction) },
  getTransaction (id) { return app.transactions.byId(id) },
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

const initLateHelpers = function () {
  if (app.transactions != null) {
    const filtered = new FilteredCollection(app.transactions)

    const getOngoingTransactionsByItemId = function (itemId) {
      filtered.resetFilters()
      filtered.filterBy('item', transac => (transac.get('item') === itemId) && !transac.archived)
      return filtered
    }

    const getOngoingTransactionsModelsByItemId = itemId => {
      return app.transactions.filter(transac => (transac.get('item') === itemId) && !transac.archived)
    }

    const getOneOngoingTransactionByItemId = itemId => getOngoingTransactionsModelsByItemId(itemId)[0]

    const hasOngoingTransactionsByItemId = itemId => getOngoingTransactionsModelsByItemId(itemId).length > 0

    app.reqres.setHandlers({
      'get:transactions:ongoing:byItemId': getOngoingTransactionsByItemId,
      'get:transaction:ongoing:byItemId': getOneOngoingTransactionByItemId,
      'has:transactions:ongoing:byItemId': hasOngoingTransactionsByItemId
    })
  }
}
