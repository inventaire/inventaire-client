{ factory:transactionsDataFactory } = require './transactions_data'

module.exports =
  listingsData: (itemListing)->
    listings = app.user.listings()
    selectedListing = listings[itemListing] or listings.private
    selectedListing.classes = 'selected'
    return listings

  transactionsData: (itemTransaction)->
    transactions = transactionsDataFactory()
    transactions.inventorying.label = 'just_inventorize_it'
    selectedTransaction = transactions[itemTransaction] or transactions.inventorying
    selectedTransaction.classes = 'selected'
    return transactions

  # assume that the view has a ui like so
  # ui:
  #   transaction: '#transaction'
  #   listing: '#listing'
  getSelectorData: (view, attr)->
    view.ui[attr].find('.selected').attr 'id'
