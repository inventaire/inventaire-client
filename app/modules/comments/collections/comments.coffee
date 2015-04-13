module.exports = Backbone.Collection.extend
  comparator: (comment)-> comment.get 'time'
