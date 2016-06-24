module.exports = Backbone.Collection.extend
  url: -> app.API.groups.authentified
  model: require '../models/group'
  otherUsersRequestsCount: ->
    @map (group)-> group.requestsCount()
    .sum()
