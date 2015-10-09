module.exports = Backbone.Collection.extend
  model: require '../models/group'
  otherUsersRequestsCount: ->
    @map (group)-> group.requestsCount()
    .sum()
