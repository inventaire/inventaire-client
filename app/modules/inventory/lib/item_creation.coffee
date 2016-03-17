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

  # assume that the view has a ui like so
  # ui:
  #   transaction: '#transaction'
  #   listing: '#listing'
  getSelectorData: (view, attr)->
    view.ui[attr].find('.active').attr 'id'
