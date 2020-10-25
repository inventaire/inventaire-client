import FilteredCollection from 'backbone-filtered-collection'
import log_ from 'lib/loggers'
import preq from 'lib/preq'
import Message from './models/message'
import poster_ from 'lib/poster'

export default function () {
  app.reqres.setHandlers({
    'transactions:add': API.addTransaction,
    'get:transaction:byId': API.getTransaction,
    'transaction:post:message': API.postMessage
  })

  return app.request('wait:for', 'user').then(initLateHelpers)
};

const API = {
  addTransaction (transaction) { return app.transactions.add(transaction) },

  getTransaction (id) { return app.transactions.byId(id) },

  postMessage (transactionId, message, timeline) {
    const messageData = {
      action: 'message',
      transaction: transactionId,
      message
    }

    const mesModel = addMessageToTimeline(messageData, timeline)

    return preq.post(app.API.transactions, messageData)
    .then(poster_.UpdateModelIdRev(mesModel))
    .catch(poster_.Rewind(mesModel, timeline))
    .catch(log_.Error('postMessage'))
  }
}

const addMessageToTimeline = function (messageData, timeline) {
  const fullMessageData = _.extend({}, messageData, {
    user: app.user.id,
    created: Date.now()
  })
  const mesModel = new Message(fullMessageData)
  timeline.add(mesModel)
  return mesModel
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
