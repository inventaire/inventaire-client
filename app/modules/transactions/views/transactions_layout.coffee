Transaction = require 'modules/transactions/views/transaction'
TransactionsList = require 'modules/transactions/views/transactions_list'

module.exports = Marionette.LayoutView.extend
  className: 'transactionsLayout'
  template: require './templates/transactions_layout'
  regions:
    activeRegion: '#active'
    archivedRegion: '#archived'
    fullviewRegion: '#fullview'

  initialize: ->
    @listenTo app.vent, 'transaction:select', @showTransactionFull.bind(@)

  onShow: ->
    app.request('waitForFriendsItems').then @showTransactionsFolders.bind(@)

  showTransactionsFolders: ->
    folders.forEach @showTransactionList.bind(@)

  showTransactionList: (folder)->
    # every folder share the app.user.transactions collection
    # but with filtered applied by TransactionsList, based on the folder name
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

# coupled to TransactionList filters
folders = ['active', 'archived']
