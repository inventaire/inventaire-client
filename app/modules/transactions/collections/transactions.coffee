module.exports = Items = Backbone.Collection.extend
  model: require '../models/transaction'
  comparator: (transaction)-> - transaction.get 'created'
