{ factory:transactionsDataFactory } = require './transactions_data'

module.exports =
  listingsData: ->
    listings = app.user.listings()
    lastListing = app.request 'last:listing:get'
    activeListing = listings[lastListing] or listings.private
    activeListing.classes = 'active'
    return listings

  transactionsData: ->
    transactions = transactionsDataFactory()
    transactions.inventorying.label = 'just_inventorize_it'
    lastTransaction = app.request 'last:transaction:get'
    activeTransaction = transactions[lastTransaction] or transactions.inventorying
    activeTransaction.classes = 'active'
    return transactions

  # assume that the view has a ui like so
  # ui:
  #   transaction: '#transaction'
  #   listing: '#listing'
  getSelectorData: (view, attr)->
    view.ui[attr].find('.active').attr 'id'
