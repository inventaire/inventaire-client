Transaction = require 'modules/transactions/views/transaction'
TransactionsList = require 'modules/transactions/views/transactions_list'

module.exports = Marionette.LayoutView.extend
  className: 'transactionsLayout'
  template: require './templates/transactions_layout'
  regions:
    notificationsRegion: '#notifications'
    receivedRegion: '#received'
    sentRegion: '#sent'
    lendingRegion: '#lending'
    borrowingRegion: '#borrowing'
    fullviewRegion: '#fullview'

  initialize: ->
    @listenTo app.vent, 'transaction:select', @showTransactionFull.bind(@)

  onShow: ->
    app.request('waitForFriendsItems').then @showTransactions.bind(@)

  showTransactions: ->
    @receivedRegion.show new TransactionsList
      state: 'received'
      collection: app.user.transactions

    @sentRegion.show new TransactionsList
      state: 'sent'
      collection: app.user.transactions

  showTransactionFull: (transaction)->
    @fullviewRegion.show new Transaction {model: transaction}

  events:
    'click label': 'toggleSection'

  toggleSection: (e)->
    region = e.currentTarget.htmlFor
    $(e.currentTarget).toggleClass 'toggled'
    $("##{region}").slideToggle(200)
