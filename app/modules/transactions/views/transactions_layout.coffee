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

  serializeData: ->
    folders: folders

  onShow: ->
    app.request 'wait:for', 'friends:items'
    # The view might have already been destroyed
    # in the case the transaction can not be found
    # and triggered the 'show:error:missing' command
    .then CheckViewState(@, 'transactions')
    .then @showTransactionsFolders.bind(@)
    .catch catchDestroyedView

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
    @fullviewRegion.show new Transaction
      model: transaction
      nonExplicitSelection: nonExplicitSelection

  events:
    'click label': 'toggleSection'

  toggleSection: (e)->
    region = e.currentTarget.htmlFor
    $(e.currentTarget).toggleClass 'toggled'
    $("##{region}").slideToggle(200)

  showTransactionWelcome: ->
    @fullviewRegion.show new TransactionsWelcome
