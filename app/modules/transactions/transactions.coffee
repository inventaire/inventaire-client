TransactionsLayout = require './views/transactions_layout'
RequestItemModal = require './views/request_item_modal'
initHelpers = require('./helpers')
lastTransactionId = null

module.exports =
  define: (module, app, Backbone, Marionette, $, _)->
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
      'transactions:unread:count': unreadCount

    initHelpers()

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
      app.request('waitForUserData')
      .then triggerTransactionSelect.bind(null, id)

  showItemRequestModal: (model)->
    if app.request 'require:loggedIn', model.pathname
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


updateTransactionRoute = (transaction, nonExplicitSelection)->
  { id } = transaction
  # if it was a nonExplicitSelection, it was just /transactions
  # which led to the first transaction being selected
  # thus the need to replace to route to avoid a loop
  if nonExplicitSelection then app.navigateReplace "transactions/#{id}"
  else app.navigate "transactions/#{id}"

findFirstTransaction = ->
  firstTransac = null
  transacs = _.clone app.user.transactions.models
  while transacs.length > 0 and not firstTransac?
    candidate = transacs.shift()
    unless candidate.archived then firstTransac = candidate

  return firstTransac

unreadCount = ->
  transac = app.user.transactions?.models
  unless transac?.length > 0 then return 0

  transac
  .map _.property('unreadUpdate')
  .reduce (a, b)-> if _.isNumber(b) then a+b else a
