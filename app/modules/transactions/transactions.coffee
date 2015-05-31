TransactionsLayout = require './views/transactions_layout'
RequestItemModal = require './views/request_item_modal'
lastTransactionId = null

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    TransactionsRouter = Marionette.AppRouter.extend
      appRoutes:
        'transactions(/)': 'showFirstTransaction'
        'transactions/:id(/)': 'showTransaction'

    app.addInitializer ->
      new TransactionsRouter
        controller: API

  initialize: ->
    @listenTo app.vent, 'transaction:select', updateTransactionRoute

    app.commands.setHandlers
      'show:item:request': API.showItemRequestModal
      'show:transactions': navigate.showTransactions
      'show:transaction': navigate.showTransaction

    app.reqres.setHandlers
      'last:transaction:id': -> lastTransactionId

    require('./helpers')()

API =
  showTransactions: ->
    if app.request 'require:loggedIn', 'transactions'
      app.layout.main.Show new TransactionsLayout, _.i18n('transactions')

  showFirstTransaction: ->
    if app.request 'require:loggedIn', 'transactions'
      @showTransactions()
      app.request('waitForUserData')
      .then findFirstTransaction
      .then (transac)->
        if transac?
          lastTransactionId = transac.id
          app.vent.trigger 'transaction:select', transac
        else
          app.vent.trigger 'transactions:welcome'
      .catch _.Error('showFirstTransaction')

  showTransaction: (id)->
    if app.request 'require:loggedIn', "transactions/#{id}"
      lastTransactionId = id
      @showTransactions()
      app.request('waitForUserData')
      .then triggerTransactionSelect.bind(null, id)

  showItemRequestModal: (model)->
    app.layout.modal.show new RequestItemModal {model: model}

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
  else app.execute 'show:404'


updateTransactionRoute = (transaction)->
  { id } = transaction
  app.navigate "transactions/#{id}"

findFirstTransaction = ->
  firstTransac = null
  transacs = _.clone app.user.transactions.models
  while transacs.length > 0 and not firstTransac?
    candidate = transacs.shift()
    unless candidate.archived then firstTransac = candidate

  return firstTransac

