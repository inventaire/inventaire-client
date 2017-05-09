Transactions = require 'modules/transactions/collections/transactions'
TransactionsLayout = require './views/transactions_layout'
RequestItemModal = require './views/request_item_modal'
initHelpers = require('./helpers')
lastTransactionId = null
fetchData = require 'lib/data/fetch'

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
    Router = Marionette.AppRouter.extend
      appRoutes:
        'transactions(/)': 'showFirstTransaction'
        'transactions/:id(/)': 'showTransaction'

    app.addInitializer -> new Router { controller: API }

  initialize: ->
    @listenTo app.vent, 'transaction:select', updateTransactionRoute

    app.commands.setHandlers
      'show:item:request': API.showItemRequestModal
      'show:transactions': navigate.showTransactions
      'show:transaction': navigate.showTransaction

    app.reqres.setHandlers
      'last:transaction:id': -> lastTransactionId
      'transactions:unread:count': unreadCount

    @listenTo app.vent, 'transaction:select', API.updateLastTransactionId

    fetchData
      name: 'transactions'
      Collection: Transactions
      condition: app.user.loggedIn
    .then app.vent.Trigger('transactions:unread:changes')
    .catch _.Error('transaction init err')

    initHelpers()

API =
  showTransactions: ->
    if app.request 'require:loggedIn', 'transactions'
      app.layout.main.show new TransactionsLayout

  showFirstTransaction: ->
    if app.request 'require:loggedIn', 'transactions'
      @showTransactions()

      app.request 'wait:for', 'transactions'
      .then findFirstTransaction
      .then (transac)->
        if transac?
          lastTransactionId = transac.id
          # replacing the url to avoid being unable to hit 'previous'
          # as previous would be '/transactions' which would redirect again
          # to the first transaction
          nonExplicitSelection = true
          app.vent.trigger 'transaction:select', transac, nonExplicitSelection
        else
          app.vent.trigger 'transactions:welcome'
      .catch _.Error('showFirstTransaction')

  showTransaction: (id)->
    if app.request 'require:loggedIn', "transactions/#{id}"
      lastTransactionId = id
      @showTransactions()

      app.request 'wait:for', 'transactions'
      .then triggerTransactionSelect.bind(null, id)

  showItemRequestModal: (model)->
    if app.request 'require:loggedIn', model.pathname
      app.layout.modal.show new RequestItemModal { model }

  updateLastTransactionId: (transac)-> lastTransactionId = transac.id

navigate =
  showTransactions: ->
    API.showFirstTransaction()
    app.navigate 'transactions'
  showTransaction: (id)->
    API.showTransaction(id)
    app.navigate "transactions/#{id}"

triggerTransactionSelect = (id)->
  transaction = app.request 'get:transaction:byId', id
  if transaction?
    app.vent.trigger 'transaction:select', transaction
  else app.execute 'show:error:missing'

updateTransactionRoute = (transaction, nonExplicitSelection)->
  { id } = transaction
  # if it was a nonExplicitSelection, it was just /transactions
  # which led to the first transaction being selected
  # thus the need to replace to route to avoid a loop
  if nonExplicitSelection then app.navigateReplace "transactions/#{id}"
  else app.navigate "transactions/#{id}"

findFirstTransaction = ->
  firstTransac = null
  transacs = _.clone app.transactions.models
  while transacs.length > 0 and not firstTransac?
    candidate = transacs.shift()
    unless candidate.archived then firstTransac = candidate

  return firstTransac

unreadCount = ->
  transac = app.transactions?.models
  unless transac?.length > 0 then return 0

  transac
  .map _.property('unreadUpdate')
  .reduce (a, b)-> if _.isNumber(b) then a+b else a
