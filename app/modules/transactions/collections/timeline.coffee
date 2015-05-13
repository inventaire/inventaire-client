module.exports = Backbone.Collection.extend
  comparator: (model)->
    # messages have a 'created' date
    # actions have a 'timestamp' date
    model.get('created') or model.get('timestamp')
