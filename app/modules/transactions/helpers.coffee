Message = require './models/message'
poster_ = require 'lib/poster'

module.exports = ->
  app.reqres.setHandlers
    'transactions:add': API.addTransaction
    'get:transaction:byId': API.getTransaction
    'transaction:post:message': API.postMessage

  app.request('wait:for', 'user').then initLateHelpers

API =
  addTransaction: (transaction)-> app.transactions.add transaction

  getTransaction: (id)-> app.transactions.byId id

  postMessage: (transactionId, message, timeline)->
    messegeData =
      action: 'message'
      transaction: transactionId
      message: message

    mesModel = addMessageToTimeline messegeData, timeline

    _.preq.post app.API.transactions, messegeData
    .then poster_.UpdateModelIdRev(mesModel)
    .catch poster_.Rewind(mesModel, timeline)
    .catch _.Error('postMessage')

addMessageToTimeline = (messegeData, timeline)->
  _.extend messegeData,
    user: app.user.id
    created: Date.now()
  mesModel = new Message messegeData
  timeline.add mesModel
  return mesModel

initLateHelpers = ->
  if app.transactions?
    filtered = new FilteredCollection app.transactions

    getOngoingTransactionsByItemId = (itemId)->
      filtered.resetFilters()
      filtered.filterBy 'item', (transac)->
        transac.get('item') is itemId and not transac.archived
      return filtered

    getOngoingTransactionsModelsByItemId = (itemId)->
      return app.transactions.filter (transac)->
        transac.get('item') is itemId and not transac.archived

    getOneOngoingTransactionByItemId = (itemId)->
      getOngoingTransactionsModelsByItemId(itemId)[0]

    hasOngoingTransactionsByItemId = (itemId)->
      getOngoingTransactionsModelsByItemId(itemId).length > 0

    app.reqres.setHandlers
      'get:transactions:ongoing:byItemId': getOngoingTransactionsByItemId
      'get:transaction:ongoing:byItemId': getOneOngoingTransactionByItemId
      'has:transactions:ongoing:byItemId': hasOngoingTransactionsByItemId
