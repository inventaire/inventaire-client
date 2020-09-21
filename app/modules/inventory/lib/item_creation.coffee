{ factory:transactionsDataFactory } = require './transactions_data'

module.exports =
  listingsData: (selectedListing)->
    selectedListing ?= app.request('last:listing:get') or 'private'
    listings = app.user.listings()
    selectedListingData = listings[selectedListing]
    selectedListingData.classes = 'selected'
    return listings

  transactionsData: (selectedTransaction)->
    selectedTransaction ?= app.request('last:transaction:get') or 'inventorying'
    transactions = transactionsDataFactory()
    transactions.inventorying.label = 'just_inventorize_it'
    selectedTransactionData = transactions[selectedTransaction]
    selectedTransactionData.classes = 'selected'
    return transactions

  # assume that the view has a ui like so
  # ui:
  #   transaction: '#transaction'
  #   listing: '#listing'
  getSelectorData: (view, attr)->
    view.ui[attr].find('.selected').attr 'id'
