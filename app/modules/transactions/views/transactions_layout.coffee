Transaction = require 'modules/transactions/views/transaction'
TransactionsList = require 'modules/transactions/views/transactions_list'
TransactionsWelcome = require './transactions_welcome'
folders = require '../lib/folders'
foldersNames = Object.keys folders

module.exports = Marionette.LayoutView.extend
  className: 'transactionsLayout'
  template: require './templates/transactions_layout'
  regions:
    ongoingRegion: '#ongoing'
    archivedRegion: '#archived'
    fullviewRegion: '#fullview'

  initialize: ->
    @listenTo app.vent, 'transaction:select', @showTransactionFull.bind(@)
    @listenTo app.vent, 'transactions:welcome', @showTransactionWelcome.bind(@)

  serializeData: ->
    folders: folders

  onShow: ->
    app.request('waitForFriendsItems').then @showTransactionsFolders.bind(@)

  showTransactionsFolders: ->
    # every folder share the app.user.transactions collection
    # but with the filter applied by TransactionsList
    # => there should be a region matching every filter's name
    foldersNames.forEach @showTransactionList.bind(@)

  showTransactionList: (folder)->
    @["#{folder}Region"].show new TransactionsList
      folder: folder
      collection: app.user.transactions

  showTransactionFull: (transaction)->
    @fullviewRegion.show new Transaction {model: transaction}

  events:
    'click label': 'toggleSection'

  toggleSection: (e)->
    region = e.currentTarget.htmlFor
    $(e.currentTarget).toggleClass 'toggled'
    $("##{region}").slideToggle(200)

  showTransactionWelcome: ->
    @fullviewRegion.show new TransactionsWelcome
