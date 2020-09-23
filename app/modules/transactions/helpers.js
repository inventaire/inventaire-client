/* eslint-disable
    import/no-duplicates,
    no-undef,
    no-var,
    prefer-arrow/prefer-arrow-functions,
*/
// TODO: This file was created by bulk-decaffeinate.
// Fix any style issues and re-enable lint.
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

var API = {
  addTransaction (transaction) { return app.transactions.add(transaction) },

  getTransaction (id) { return app.transactions.byId(id) },

  postMessage (transactionId, message, timeline) {
    const messageData = {
      action: 'message',
      transaction: transactionId,
      message
    }

    const mesModel = addMessageToTimeline(messageData, timeline)

    return _.preq.post(app.API.transactions, messageData)
    .then(poster_.UpdateModelIdRev(mesModel))
    .catch(poster_.Rewind(mesModel, timeline))
    .catch(_.Error('postMessage'))
  }
}

var addMessageToTimeline = function (messageData, timeline) {
  const fullMessageData = _.extend({}, messageData, {
    user: app.user.id,
    created: Date.now()
  }
  )
  const mesModel = new Message(fullMessageData)
  timeline.add(mesModel)
  return mesModel
}

var initLateHelpers = function () {
  if (app.transactions != null) {
    const filtered = new FilteredCollection(app.transactions)

    const getOngoingTransactionsByItemId = function (itemId) {
      filtered.resetFilters()
      filtered.filterBy('item', transac => (transac.get('item') === itemId) && !transac.archived)
      return filtered
    }

    const getOngoingTransactionsModelsByItemId = itemId => app.transactions.filter(transac => (transac.get('item') === itemId) && !transac.archived)

    const getOneOngoingTransactionByItemId = itemId => getOngoingTransactionsModelsByItemId(itemId)[0]

    const hasOngoingTransactionsByItemId = itemId => getOngoingTransactionsModelsByItemId(itemId).length > 0

    return app.reqres.setHandlers({
      'get:transactions:ongoing:byItemId': getOngoingTransactionsByItemId,
      'get:transaction:ongoing:byItemId': getOneOngoingTransactionByItemId,
      'has:transactions:ongoing:byItemId': hasOngoingTransactionsByItemId
    })
  }
}
