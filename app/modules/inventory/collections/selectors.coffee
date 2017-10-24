module.exports = Backbone.Collection.extend
  comparator: (model)-> - model.get('count')
