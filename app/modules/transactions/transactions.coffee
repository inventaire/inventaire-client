TransactionsLayout = require './views/transactions_layout'
RequestItemModal = require './views/request_item_modal'
Message = require './models/message'
poster_ = require 'lib/poster'

module.exports =
  define: (module, app, Backbone, Marionette, $, _) ->
    TransactionsRouter = Marionette.AppRouter.extend
      appRoutes:
        'transactions(/)': 'showTransactions'
        'transactions/:id(/)': 'showTransaction'

    app.addInitializer ->
      new TransactionsRouter
        controller: API

  initialize: ->
    @listenTo app.vent, 'transaction:select', updateTransactionRoute

    app.commands.setHandlers
      'show:item:request': API.showItemRequestModal
      'show:transactions': ->
        API.showTransactions()
        app.navigate 'transactions'
      'show:transactions': (id)->
        API.showTransaction(id)
        app.navigate "transactions/#{id}"

    require('./helpers')()

API =
  showTransactions: ->
    if app.request 'require:loggedIn', 'transactions'
      app.layout.main.Show new TransactionsLayout, _.i18n('transactions')

  showTransaction: (id)->
    if app.request 'require:loggedIn', "transactions/#{id}"
      @showTransactions()
      app.request('waitForUserData')
      .then triggerTransactionSelect.bind(null, id)

  showItemRequestModal: (model)->
    app.layout.modal.show new RequestItemModal {model: model}


triggerTransactionSelect = (id)->
  transaction = app.request 'get:transaction:byId', id
  if transaction?
    app.vent.trigger 'transaction:select', transaction


updateTransactionRoute = (transaction)->
  { id } = transaction
  app.navigate "transactions/#{id}"
