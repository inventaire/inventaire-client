module.exports = Backbone.Collection.extend
  url: -> app.API.transactions
  model: require '../models/transaction'
  comparator: (transaction)-> -transaction.get('created')
