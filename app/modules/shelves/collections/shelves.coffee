module.exports = Backbone.Collection.extend
  model: require '../models/shelf'

  initialize: (models, options = {})->
    @selected = options.selected or []

  comparator: (shelf)->
    if shelf.id in @selected then '0' + shelf.get('name').toLowerCase()
    else '1' + shelf.get('name').toLowerCase()
