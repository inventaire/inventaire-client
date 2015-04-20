module.exports = Backbone.Collection.extend
  model: require '../models/comment'
  comparator: (comment)-> comment.get 'created'
  initialize: (comments, options)->
    # keeping a reference to the item
    @item = options.item
