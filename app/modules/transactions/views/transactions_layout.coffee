Transaction = require 'modules/transactions/views/transaction'
TransactionsList = require 'modules/transactions/views/transactions_list'
TransactionsWelcome = require './transactions_welcome'
folders = require '../lib/folders'
foldersNames = Object.keys folders
{ CheckViewState, catchDestroyedView } = require 'lib/view_state'

module.exports = Marionette.LayoutView.extend
  className: 'transactionsLayout'
  template: require './templates/transactions_layout'
  regions:
    ongoingRegion: '#ongoing'
    archivedRegion: '#archived'
    fullviewRegion: '#fullview'

  initialize: ->
    @listenTo app.vent,
      'transaction:select': @showTransactionFull.bind(@)
      'transactions:welcome': @showTransactionWelcome.bind(@)

  serializeData: -> { folders }

  onShow: -> @showTransactionsFolders()

  showTransactionsFolders: ->
    # every folder share the app.transactions collection
    # but with the filter applied by TransactionsList
    # => there should be a region matching every filter's name
    for folder in foldersNames
      @showTransactionList folder

  showTransactionList: (folder)->
    @["#{folder}Region"].show new TransactionsList
      folder: folder
      collection: app.transactions

  showTransactionFull: (transaction, nonExplicitSelection)->
    @fullviewRegion.show new Transaction { model: transaction, nonExplicitSelection }

  events:
    'click label': 'toggleSection'

  toggleSection: (e)->
    region = e.currentTarget.htmlFor
    $(e.currentTarget).toggleClass 'toggled'
    $("##{region}").slideToggle(200)

  showTransactionWelcome: -> @fullviewRegion.show new TransactionsWelcome
