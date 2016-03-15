module.exports =
  listingsData: ->
    listings = app.user.listings()
    listings.private.classes = 'active'
    return listings

  transactionsData: ->
    transactions = app.items.transactions()
    _.extend transactions.inventorying,
      label: 'just_inventorize_it'
      classes: 'active'
    return transactions
